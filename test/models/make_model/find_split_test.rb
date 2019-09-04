require 'test_helper'

class MakeModel::FindSplitTest < ActiveSupport::TestCase
  test 'splits' do
    mm = MakeModel.split_make_model('Pitts S-1S')
    assert_equal('Pitts', mm[0])
    assert_equal('S-1S', mm[1])
    mm = MakeModel.split_make_model('Decathlon')
    assert_nil(mm[0])
    assert_equal('Decathlon', mm[1])
    mm = MakeModel.split_make_model('Extra 330 LX')
    assert_equal('Extra', mm[0])
    assert_equal('330 LX', mm[1])
  end

  test 'finds exact' do
    target = create(:make_model)
    mm = MakeModel.find_or_create_makemodel(
      [target.make, target.model].join(' '))
    refute_nil(mm)
    assert_equal(target.id, mm.id)
  end

  test 'finds case insensitive' do
    target = create(:make_model)
    mm = MakeModel.find_or_create_makemodel(
      [target.make.upcase, target.model.upcase].join(' '))
    refute_nil(mm)
    assert_equal(target.make, mm.make)
    assert_equal(target.model, mm.model)
  end

  test 'finds with hyphen' do
    target = create(:make_model)
    mm = MakeModel.find_or_create_makemodel(
      [target.make, target.model].join('-'))
    refute_nil(mm)
    assert_equal(target.make, mm.make)
    assert_equal(target.model, mm.model)
  end

  test 'finds reversed' do
    target = create(:make_model)
    mm = MakeModel.find_or_create_makemodel(
      [target.model, target.make].join(' '))
    refute_nil(mm)
    assert_equal(target.make, mm.make)
    assert_equal(target.model, mm.model)
  end

  test 'finds given extra in the middle' do
    target = create(:make_model)
    mm = MakeModel.find_or_create_makemodel(
      [target.model, '8KCAB', target.make].join(' '))
    refute_nil(mm)
    assert_equal(target.make, mm.make)
    assert_equal(target.model, mm.model)
  end

  test 'finds given extra at the end' do
    target = create(:make_model)
    mm = MakeModel.find_or_create_makemodel(
      [target.model, target.make, '8KCAB'].join(' '))
    refute_nil(mm)
    assert_equal(target.make, mm.make)
    assert_equal(target.model, mm.model)
  end

  test 'robust to apostrophy in name' do
    target = create(:make_model, make: "a'poc'ry'phal")
    mm = MakeModel.find_or_create_makemodel(
      [target.model, target.make].join(' '))
    refute_nil(mm)
    assert_equal(target.make, mm.make)
    assert_equal(target.model, mm.model)
  end

  test 'creates missing' do
    target = build(:make_model)
    refute(target.persisted?)
    mm = MakeModel.find_or_create_makemodel(
      [target.make, target.model].join(' '))
    refute_nil(mm)
    assert_equal(target.make, mm.make)
    assert_equal(target.model, mm.model)
  end
end
