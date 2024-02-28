# my_broadway.ex

defmodule MyBroadway do
  use Broadway

  alias Broadway.Message

  def start_link(_opts) do
    Broadway.start_link(__MODULE__,
      name: __MODULE__,
      producer: [
        module: {BroadwaySQS.Producer, queue_url: "https://us-east-1.queue.amazonaws.com/123456789012/my_queue"}
      ],
      processors: [
        default: [concurrency: 10]
      ],
      batchers: [
        stats: [concurrency: 2, batch_size: 50, batch_timeout: 5000]
      ]
    )
  end

  def handle_message(_, message, _) do
    # Parse the CSV data from the message and convert it to a list of maps
    data = message.data
          |> String.split("\n")
          |> Enum.map(&String.split(&1, ","))
          |> List.to_tuple()
          |> :csv.decode()

    # Transform the data by adding a new column with the sum of the first two columns
    data = Enum.map(data, fn row ->
    Map.put(row, :sum, row.Column1 + row.Column2)
  end)

    # Put the data in the batcher :stats
    message
       |> Message.update_data(fn _ -> data end)
       |> Message.put_batcher(:stats)
  end

  def handle_batch(:stats, messages, _batch_info, _) do
    # Get the data from the messages
    data = messages |> Enum.map(& &1.data) |> List.flatten()

    # Aggregate the data by calculating the average of each column
    averages = data
         |> Enum.reduce(%{}, fn row, acc ->
            Enum.reduce(row, acc, fn {key, value}, acc ->
            Map.update(acc, key, value, &(&1 + value))
     end)
   end)
   |> Enum.map(fn {key, value} ->
      {key, value / length(data)}
    end)
    |> Enum.into(%{})

    # Print the averages
    IO.inspect(averages)
  end
end

