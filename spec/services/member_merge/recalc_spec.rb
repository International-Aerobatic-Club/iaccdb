module MemberMerge
  describe Merge, :type => :services do
    before :context do
      # mr = member record
      @mra = create_list(:member, 4)
      @mr_ids = @mra.collect(&:id)
      @target_mr = @mra[0]
      @replace_mr = @mra[1]
      @replaced_mra = Array.new(@mra).delete(@target_mr)
      @t_contest = create :contest
      @r_contest = create :contest
    end

    context 'competitor as target and replaced' do
      before :context do
        start_transaction # database cleaner embedded context
        t_flight = create :flight, contest: @t_contest
        create :pilot_flight, pilot: @target_mr, flight: t_flight

        r_flight = create :flight, contest: @r_contest
        create :pilot_flight, pilot: @replace_mr, flight: r_flight

        @merge = MemberMerge::Merge.new(@mr_ids)
      end
      after :context do
        end_transaction
      end
      it 'computes replaced member contests as competitor' do
        expect(@merge).to receive(:recompute_pilot_rollups).once.with(@r_contest)
        @merge.execute_merge(@target_mr)
      end
      it 'does not recompute target member contests as competitor' do
        expect(@merge).to_not receive(:recompute_pilot_rollups).with(@t_contest)
        @merge.execute_merge(@target_mr)
      end
    end

    context 'judge as target and replaced' do
      before :context do
        start_transaction
        t_judge = create :judge, judge: @target_mr
        t_flight = create :flight, contest: @t_contest
        t_pf = create :pilot_flight, flight: t_flight
        create :score, judge: t_judge, pilot_flight: t_pf

        r_judge = create :judge, judge: @replace_mr
        r_flight = create :flight, contest: @r_contest
        r_pf = create :pilot_flight, flight: r_flight
        create_list :score, 8, judge: r_judge, pilot_flight: r_pf

        @merge = MemberMerge::Merge.new(@mr_ids)
      end
      after :context do
        end_transaction
      end
      it 'computes replaced member contests as judge' do
        expect(@merge).to receive(:recompute_judge_rollups).once.with(@r_contest)
        @merge.execute_merge(@target_mr)
      end
      it 'does not recompute target member contests as judge' do
        expect(@merge).to_not receive(:recompute_judge_rollups).with(@t_contest)
        @merge.execute_merge(@target_mr)
      end
    end

    context 'competitor as target, judge as replaced' do
      before :context do
        start_transaction
        t_flight = create :flight, contest: @t_contest
        create :pilot_flight, pilot: @target_mr, flight: t_flight

        r_judge = create :judge, judge: @replace_mr
        r_flight = create :flight, contest: @r_contest
        r_pf = create :pilot_flight, flight: r_flight
        create_list :score, 8, judge: r_judge, pilot_flight: r_pf

        @merge = MemberMerge::Merge.new(@mr_ids)
      end
      after :context do
        end_transaction
      end
      it 'computes replaced member contests as judge' do
        expect(@merge).to receive(:recompute_judge_rollups).once.with(@r_contest)
        @merge.execute_merge(@target_mr)
      end
      it 'does not recompute target member contests' do
        expect(@merge).to_not receive(:recompute_judge_rollups).with(@t_contest)
        expect(@merge).to_not receive(:recompute_pilot_rollups)
        @merge.execute_merge(@target_mr)
      end
    end

    context 'judge as target, competitor as replaced' do
      before :context do
        start_transaction
        t_judge = create :judge, judge: @target_mr
        t_flight = create :flight, contest: @t_contest
        t_pf = create :pilot_flight, flight: t_flight
        create :score, judge: t_judge, pilot_flight: t_pf

        r_flight = create :flight, contest: @r_contest
        create :pilot_flight, pilot: @replace_mr, flight: r_flight

        @merge = MemberMerge::Merge.new(@mr_ids)
      end
      after :context do
        end_transaction
      end
      it 'computes replaced member contests as competitor' do
        expect(@merge).to receive(:recompute_pilot_rollups).once.with(@r_contest)
        @merge.execute_merge(@target_mr)
      end
      it 'does not recompute target member contests' do
        expect(@merge).to_not receive(:recompute_judge_rollups)
        expect(@merge).to_not receive(:recompute_pilot_rollups).with(@t_contest)
        @merge.execute_merge(@target_mr)
      end
    end
  end
end
