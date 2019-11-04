if airplane
  json.airplane do
    json.make airplane.make_model.make
    json.model airplane.make_model.model
    json.reg airplane.reg
  end
end
