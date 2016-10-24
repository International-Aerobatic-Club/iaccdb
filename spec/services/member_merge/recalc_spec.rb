module MemberMerge
  describe Merge, :type => :services do
    before :each do
      # mr = member record
      @mra = create_list(:member, 4)
      @mr_ids = @mra.collect(&:id)
      @target_mr = @mra[0]
      @replace_mr = @mra[1]
      @t_contest = create :contest
      @r_contest = create :contest, year: @t_contest.year
    end

    # creates computed artifacts - jf, jc, pf, pc_results
    # returns the MemberMerge service
    # you call execute_merge(@target_mr) on that when ready
    def prepare_contest_landscape
      cc = ContestComputer.new(@t_contest)
      cc.compute_results
      cc = ContestComputer.new(@r_contest)
      cc.compute_results
      MemberMerge::Merge.new(@mr_ids)
    end

    context 'competitor as target and replaced' do
      before :each do
        t_flight = create :flight, contest: @t_contest
        t_pf = create :pilot_flight, pilot: @target_mr, flight: t_flight
        create :score, pilot_flight: t_pf

        r_flight = create :flight, contest: @r_contest
        r_pf = create :pilot_flight, pilot: @replace_mr, flight: r_flight
        create :score, pilot_flight: r_pf

        merge = prepare_contest_landscape
        merge.execute_merge(@target_mr)
      end
      it 'retains results for contests not altered' do
        pcrs = PcResult.where(pilot: @target_mr, contest: @t_contest)
        expect(pcrs.count).to eq 1
      end
      it 'removes results for altered contests' do
        pcrs = PcResult.where(pilot: @replace_mr, contest: @r_contest)
        expect(pcrs.count).to eq 0
      end
      it 'computes replaced member contests as competitor' do
        pcrs = PcResult.where(pilot: @target_mr, contest: @r_contest)
        expect(pcrs.count).to eq 0
        work_result = Delayed::Worker.new.work_off
        expect(work_result[1]).to eq 0
        pcrs = PcResult.where(pilot: @target_mr, contest: @r_contest)
        expect(pcrs.count).to eq 1
      end
      it 'queues jobs to recompute pilot rollups' do
        expect(Delayed::Job.count).to eq 1
      end
      it 'does not recompute target member contests as competitor' do
        pcrs = PcResult.where(pilot: @target_mr, contest: @t_contest)
        expect(pcrs.count).to eq 1
        pcr = pcrs.first
        work_result = Delayed::Worker.new.work_off
        expect(work_result[1]).to eq 0
        pcrs = PcResult.where(pilot: @target_mr, contest: @t_contest)
        expect(pcrs.count).to eq 1
        expect(pcrs.first.id).to eq pcr.id
      end
    end

    context 'judge as target and replaced' do
      before :each do
        t_judge = create :judge, judge: @target_mr
        t_flight = create :flight, contest: @t_contest
        t_pf = create :pilot_flight, flight: t_flight
        create :score, judge: t_judge, pilot_flight: t_pf

        r_judge = create :judge, judge: @replace_mr
        r_flight = create :flight, contest: @r_contest
        r_pf = create :pilot_flight, flight: r_flight
        create :score, judge: r_judge, pilot_flight: r_pf

        @merge = prepare_contest_landscape
        @merge.execute_merge(@target_mr)
      end
      it 'does not remove target member contests not altered' do
        jcrs = JcResult.where(judge: @target_mr, contest: @t_contest)
        expect(jcrs.count).to eq 1
      end
      it 'removes replaced member contest results' do
        jcrs = JcResult.where(judge: @replace_mr)
        expect(jcrs.count).to eq 0
      end
      it 'queues jobs to recompute judge rollups' do
        expect(Delayed::Job.count).to eq 1
      end
      it 'recomputes replaced member contests as judge' do
        jcrs = JcResult.where(judge: @target_mr, contest: @r_contest)
        expect(jcrs.count).to eq 0
        work_result = Delayed::Worker.new.work_off
        expect(work_result[1]).to eq 0
        jcrs = JcResult.where(judge: @target_mr, contest: @r_contest)
        expect(jcrs.count).to eq 1
      end
      it 'does not recompute target member contests as judge' do
        jcrs = JcResult.where(judge: @target_mr, contest: @t_contest)
        expect(jcrs.count).to eq 1
        jcr = jcrs.first
        work_result = Delayed::Worker.new.work_off
        expect(work_result[1]).to eq 0
        jcrs = JcResult.where(judge: @target_mr, contest: @t_contest)
        expect(jcrs.count).to eq 1
        expect(jcrs.first).to eq jcr
      end
      it 'recomputes year result for target member' do
        jyrs = JyResult.where(judge: @target_mr)
        expect(jyrs.count).to eq 0
        work_result = Delayed::Worker.new.work_off
        expect(work_result[1]).to eq 0
        jyrs = JyResult.all
        jyrs = JyResult.where(judge: @target_mr)
        expect(jyrs.count).to eq 1
      end
    end

    context 'competitor as target, judge as replaced' do
      before :each do
        t_flight = create :flight, contest: @t_contest
        t_pf = create :pilot_flight, pilot: @target_mr, flight: t_flight
        create :score, pilot_flight: t_pf

        r_judge = create :judge, judge: @replace_mr
        r_flight = create :flight, contest: @r_contest
        r_pf = create :pilot_flight, flight: r_flight
        create :score, judge: r_judge, pilot_flight: r_pf

        merge = prepare_contest_landscape
        merge.execute_merge(@target_mr)
      end
      it 'recomputes replaced member contests as judge' do
        jcrs = JcResult.where(judge: @target_mr, contest: @r_contest)
        expect(jcrs.count).to eq 0
        work_result = Delayed::Worker.new.work_off
        expect(work_result[1]).to eq 0
        jcrs = JcResult.where(judge: @target_mr, contest: @r_contest)
        expect(jcrs.count).to eq 1
      end
      it 'does not recompute target member contests' do
        pcrs = PcResult.where(pilot: @target_mr, contest: @t_contest)
        expect(pcrs.count).to eq 1
        pcr = pcrs.first
        work_result = Delayed::Worker.new.work_off
        expect(work_result[1]).to eq 0
        pcrs = PcResult.where(pilot: @target_mr, contest: @t_contest)
        expect(pcrs.count).to eq 1
        expect(pcrs.first).to eq pcr
      end
    end

    context 'judge as target, competitor as replaced' do
      before :each do
        t_judge = create :judge, judge: @target_mr
        t_flight = create :flight, contest: @t_contest
        t_pf = create :pilot_flight, flight: t_flight
        create :score, judge: t_judge, pilot_flight: t_pf

        r_flight = create :flight, contest: @r_contest
        r_pf = create :pilot_flight, pilot: @replace_mr, flight: r_flight
        create :score, pilot_flight: r_pf # any judge will do

        merge = prepare_contest_landscape
        merge.execute_merge(@target_mr)
      end
      it 'recomputes replaced member contests as competitor' do
        pcrs = PcResult.where(pilot: @target_mr, contest: @r_contest)
        expect(pcrs.count).to eq 0
        work_result = Delayed::Worker.new.work_off
        expect(work_result[1]).to eq 0
        pcrs = PcResult.where(pilot: @target_mr, contest: @r_contest)
        expect(pcrs.count).to eq 1
      end
      it 'does not recompute target member contests as judge' do
        jcrs = JcResult.where(judge: @target_mr, contest: @t_contest)
        expect(jcrs.count).to eq 1
        jcr = jcrs.first
        work_result = Delayed::Worker.new.work_off
        expect(work_result[1]).to eq 0
        jcrs = JcResult.where(judge: @target_mr, contest: @t_contest)
        expect(jcrs.count).to eq 1
        expect(jcrs.first).to eq jcr
      end
    end

    context 'cleanup obsolete result rollups before recomputation' do
      before :each do
        @replaced_mra = @mra.reject{ |m| m == @target_mr }
      end
      context 'for judge' do
        before :each do
          t_jc_result = create :jc_result, contest: @t_contest, judge: @target_mr
          t_cat = t_jc_result.category
          t_jy_result = create :jy_result, year: @t_contest.year,
            judge: @target_mr, category: t_cat
          t_flight = create :flight, contest: @t_contest, category: t_cat
          t_pf = create :pilot_flight, flight: t_flight
          t_jp = create :judge, judge: @target_mr
          create :score, judge: t_jp, pilot_flight: t_pf

          r_jc_result = create :jc_result, contest: @r_contest, judge: @replace_mr
          r_cat = r_jc_result.category
          r_jy_result = create :jy_result, year: @r_contest.year,
            judge: @replace_mr, category: r_cat
          r_flight = create :flight, contest: @r_contest, category: r_cat
          r_pf = create :pilot_flight, flight: r_flight
          r_jp = create :judge, judge: @replace_mr
          create :score, judge: r_jp, pilot_flight: r_pf

          @merge = prepare_contest_landscape
        end

        it 'maintains jy_results for target' do
          before = JyResult.where(judge: @target_mr).all.to_a
          expect(before.length).to_not eq 0
          @merge.execute_merge(@target_mr)
          after = JyResult.where(judge: @target_mr).all.to_a
          expect(after).to match_array(before)
        end

        it 'removes jy_results for replaced' do
          before = JyResult.where(judge: @replaced_mra)
          expect(before.count).to_not eq 0
          @merge.execute_merge(@target_mr)
          jy_results = JyResult.where(judge: @replaced_mra)
          expect(jy_results.count).to eq 0
        end

        it 'maintains jc_results for target' do
          before = JcResult.where(judge: @target_mr).all.to_a
          expect(before.length).to_not eq 0
          @merge.execute_merge(@target_mr)
          after = JcResult.where(judge: @target_mr).all.to_a
          expect(after).to match_array(before)
        end

        it 'removes jc_results for replaced' do
          before = JcResult.where(judge: @replaced_mra)
          expect(before.count).to_not eq 0
          @merge.execute_merge(@target_mr)
          jc_results = JcResult.where(judge: @replaced_mra)
          expect(jc_results.count).to eq 0
        end
      end

      context 'for competitor' do
        before :each do
          t_flight = create :flight, contest: @t_contest
          t_pf = create :pilot_flight, flight: t_flight, pilot: @target_mr
          create :score, pilot_flight: t_pf
          t_cat = t_flight.category
          create :pc_result, pilot: @target_mr, contest: @t_contest,
            category: t_cat

          r_flight = create :flight, contest: @r_contest
          r_pf = create :pilot_flight, flight: r_flight, pilot: @replace_mr
          create :score, pilot_flight: r_pf
          r_cat = r_flight.category
          create :pc_result, pilot: @replace_mr, contest: @r_contest,
            category: r_cat

          @merge = prepare_contest_landscape
        end

        it 'maintains pc_results for target' do
          before = PcResult.where(pilot: @target_mr).all.to_a
          expect(before.count).to_not eq 0
          @merge.execute_merge(@target_mr)
          after = PcResult.where(pilot: @target_mr).all.to_a
          expect(after).to match_array(before)
        end

        it 'removes pc_results for replaced' do
          before = PcResult.where(pilot: @replace_mr).all.to_a
          expect(before.count).to_not eq 0
          @merge.execute_merge(@target_mr)
          pc_results = PcResult.where(pilot: @replace_mr).all
          expect(pc_results.empty?).to be(true)
        end
      end
    end
  end
end
