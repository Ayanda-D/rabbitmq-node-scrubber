-module(rabbit_node_scrubber).

-export([ scrub/1, leave_cluster/0, leave_cluster/1 ]).

scrub(Node) ->
  AllNodes = rabbit_mnesia:cluster_nodes(all) -- [Node],
  {Replies, BadNodes} = rpc:multicall(AllNodes, rabbit_mnesia, remove_node_if_mnesia_running, [Node]),
  case lists:filter(fun(Reply) -> ok /= Reply end, Replies) of
    [] ->
      output("RabbitMQ Node Scrubber executed successfully", []);
    ErrorReplies ->
      output("RabbitMQ Node Scrubber reported failures: ~p replies and ~p bad nodes", [ErrorReplies, BadNodes])
  end,
  ok.

leave_cluster() ->
    case nodes_excl_me(rabbit_mnesia:cluster_nodes(all)) of
        []       -> ok;
        AllNodes -> case lists:any(fun leave_cluster/1, AllNodes) of
                        true  -> ok;
                        false -> e(no_running_cluster_nodes)
                    end
    end.

leave_cluster(Node) ->
    case rpc:call(Node,
                  rabbit_mnesia, remove_node_if_mnesia_running, [node()]) of
        ok                          -> true;
        {error, mnesia_not_running} -> false;
        {error, Reason}             -> throw({error, Reason});
        {badrpc, nodedown}          -> false
    end.

nodes_excl_me(Nodes) -> Nodes -- [node()].

e(Tag) -> throw({error, {Tag, "You cannot leave a cluster if no online nodes are present."}}).

output(Format, Args) ->
  rabbit_log:info(Format, Args),
  io:format(Format, Args).
