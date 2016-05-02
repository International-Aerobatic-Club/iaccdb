require 'xml'

module Jasper
  describe JasperParse do
    before(:context) do
      @jasper = Jasper::JasperParse.new
      parser = XML::Parser.file('spec/fixtures/jasper/jasperResultsFormat.xml')
      @jasper.do_parse(parser)
    end
    it 'captures a contest' do
      expect(@jasper.contest_name).to eq('Test Contest US Candian Challenge')
      expect(@jasper.contest_city).to eq('Olean')
      expect(@jasper.contest_state).to eq('NY')
      expect(@jasper.contest_chapter).to eq('126')
      expect(@jasper.contest_region).to eq('NorthEast')
      expect(@jasper.contest_director).to eq('Pat Barrett')
      cDate = @jasper.contest_date
      expect(cDate).not_to be_nil
      expect(cDate.mon).to eq(12)
      expect(cDate.day).to eq(23)
      expect(cDate.year).to eq(2014)
      expect(@jasper.aircat).to eq('P')
    end
    it 'gives category names' do
      expect(@jasper.category_name(1)).to eq('Primary')
      expect(@jasper.category_name(2)).to eq('Sportsman')
      expect(@jasper.category_name(3)).to eq('Intermediate')
      expect(@jasper.category_name(4)).to eq('Advanced')
      expect(@jasper.category_name(5)).to eq('Unlimited')
      expect(@jasper.category_name(6)).to eq('Four Minute')
    end
    it 'gives categories scored' do
      expect(@jasper.categories_scored).to eq([2,3,4,5,6])
    end
    it 'gives flights scored' do
      expect(@jasper.flights_scored(2)).to eq([1,2,3])
    end
    it 'gives pilots scored' do
      expect(@jasper.pilots_scored(2,2)).to eq([1,2,3,4])
    end
    it 'gives judge teams for flight' do
      expect(@jasper.judge_teams(2,2)).to eq([0,1,2,3])
    end
    it 'gives chief judge' do
      expect(@jasper.chief_iac_number(3,2)).to eq('2383')
      expect(@jasper.chief_first_name(3,2)).to eq('Carole')
      expect(@jasper.chief_last_name(3,2)).to eq('Holyk')
    end
    it 'gives chief assistant' do
      expect(@jasper.chief_assist_iac_number(3,2)).to eq('28094')
      expect(@jasper.chief_assist_first_name(3,2)).to eq('William')
      expect(@jasper.chief_assist_last_name(3,2)).to eq('Gordon')
    end
    it 'gives pilot' do
      expect(@jasper.pilot_iac_number(2,3)).to eq('434969')
      expect(@jasper.pilot_first_name(2,3)).to eq('Desmond')
      expect(@jasper.pilot_last_name(2,3)).to eq('Lightbody')
      expect(@jasper.pilot_chapter(2,3)).to eq('3')
    end
    it 'gives airplane' do
      expect(@jasper.airplane_make(4,1)).to eq('Sukoi')
      expect(@jasper.airplane_model(4,1)).to eq('29')
      expect(@jasper.airplane_reg(4,1)).to eq('54CP')
    end
    it 'gives judge' do
      expect(@jasper.judge_iac_number(2,1,1)).to eq('431885')
      expect(@jasper.judge_first_name(2,1,1)).to eq('Sanford')
      expect(@jasper.judge_last_name(2,1,1)).to eq('Langworthy')
    end
    it 'gives judge assistant' do
      expect(@jasper.judge_assist_iac_number(2,1,1)).to eq('433272')
      expect(@jasper.judge_assist_first_name(2,1,1)).to eq('Hella')
      expect(@jasper.judge_assist_last_name(2,1,1)).to eq('Comat')
    end
    it 'gives penalty' do
      expect(@jasper.penalty(3,3,1)).to eq(100)
    end
    it 'gives grades' do
      expect(@jasper.grades_for(2,1,1,1)).to eq('-1.0 8.5 8.5 9.0 8.5 9.0 9.0 9.0 8.5 9.5 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 8.5 ') 
    end
    it 'gives k values' do
      expect(@jasper.k_values_for(1, 2, 1)).to eq('7 15 14 10 4 10 0 0 0 0 0 0 0 0 0 0 0 0 0 0 3 ')
      expect(@jasper.k_values_for(2, 1, 1)).to eq('17 7 4 14 15 16 14 17 10 10 0 0 0 0 0 0 0 0 0 0 6 ')
      expect(@jasper.k_values_for(2, 1, 2)).to eq('17 7 4 14 15 16 14 17 10 10 0 0 0 0 0 0 0 0 0 0 6 ')
      expect(@jasper.k_values_for(2, 2, 1)).to eq('17 7 4 14 15 16 14 17 10 10 0 0 0 0 0 0 0 0 0 0 6 ')
      expect(@jasper.k_values_for(2, 2, 2)).to eq('7 14 19 18 10 14 13 16 11 5 0 0 0 0 0 0 0 0 0 0 6 ')
      expect(@jasper.k_values_for(2, 3, 1)).to eq('17 7 4 14 15 16 14 17 10 10 0 0 0 0 0 0 0 0 0 0 6 ')
      expect(@jasper.k_values_for(2, 3, 2)).to eq('7 14 19 18 10 14 13 16 11 5 0 0 0 0 0 0 0 0 0 0 6 ')
      expect(@jasper.k_values_for(3, 2, 1)).to eq('9 10 15 14 11 19 10 13 17 16 11 17 14 14 0 0 0 0 0 0 8 ')
      expect(@jasper.k_values_for(3, 3, 1)).to eq('32 17 10 20 10 17 19 15 20 13 0 0 0 0 0 0 0 0 0 0 8 ')
    end
    it 'finds collegiate competitors' do
      cps = @jasper.collegiate_pilots(2)
      expect(cps.length).to eq 3
      expect(cps).to include '1'
      expect(cps).to include '2'
      expect(cps).to include '4'
    end
    it 'finds collegiate competitor colleges' do
      college = 'University of North Dakota'
      expect(@jasper.pilot_college(3,1)).to eq college
      expect(@jasper.pilot_college(3,2)).to eq college
      expect(@jasper.pilot_college(3,3)).to eq college
      expect(@jasper.pilot_college(3,5)).to eq nil
    end
  end
end
