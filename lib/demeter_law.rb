module DemeterLaw
  def demeter(symbol)
    define_method :method_missing do |method, *args|
      message_split = method.to_s.split("_")
      object = self.send(message_split.first)
      message_split.delete message_split.first
      object.send(message_split.join("_"))
    end
  end
end
