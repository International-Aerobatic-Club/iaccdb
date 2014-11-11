module ApplicationHelper
  def decimal_two(v)
    sprintf('%.02f', v  ? v : 0)
  end

  def score_two(v)
    v ||= 0
    decimal_two(v.fdiv(10))
  end

  def score_pct_two(n,d)
    n ||= 0
    d ||= 1
    decimal_two((n * 100.0).fdiv(d))
  end

  def k_score_two(k)
    k ||= 0
    decimal_two(k * 10)
  end

  def link_to_add_fields(name, form, association)
    new_object = form.object.send(association).klass.new
    id = new_object.object_id
    fields = form.fields_for(association, new_object, child_index: id) do |fm|
      render(association.to_s.singularize + '_fields', fm: fm)
    end
    link_to(name, '#', class: 'add_fields', data: {id: id, fields: fields.gsub("\n", '')})
  end
end
