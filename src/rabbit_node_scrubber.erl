-module(rabbit_node_scrubber).

-export([ scrub/1 ]).

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

output(Format, Args) ->
  rabbit_log:info(Format, Args),
  io:format(Format, Args).
