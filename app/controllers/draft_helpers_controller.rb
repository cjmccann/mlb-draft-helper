class DraftHelpersController < ApplicationController
  def index
  end

  def show
    @draft_helper = DraftHelper.find(params[:id])
    @data_manager = @draft_helper.data_manager

    @my_team = @draft_helper.league.my_team
    @my_team_players = @my_team.get_slots_with_players

    @other_team_players = [ ]
    @draft_helper.league.teams.each do |team|
      if team.name != 'My Team'
        @other_team_players.push(team.get_slots_with_players)
      end
    end

    @sorted_lists = [ ]
    @sorted_lists.push({ :div_id => 'availablePlayersCumulative',
                         :value_label => 'Cumulative % diff',
                         :list => @draft_helper.data_manager.get_sorted_players_list })
    authorize! :read, @draft_helper
  end

  def availablePlayersAbsolute
    @draft_helper = DraftHelper.find(params[:id])
    @sorted_lists = [{ :div_id => 'availablePlayersAbsolute',
                         :value_label => 'Absolute % sum',
                         :list => @draft_helper.data_manager.get_sorted_players_list_absolute_percentiles }]
    render :partial => 'player_table'
  end

  def availablePlayersAbsolutePos
    @draft_helper = DraftHelper.find(params[:id])
    @sorted_lists = [{ :div_id => 'availablePlayersAbsolutePos',
                         :value_label => 'Abs. % sum, pos adj',
                         :list => @draft_helper.data_manager.get_sorted_players_list_with_pos_adjustments }]
    render :partial => 'player_table'
  end

  def availablePlayersAbsolutePosSlot
    @draft_helper = DraftHelper.find(params[:id])
    @sorted_lists = [{ :div_id => 'availablePlayersAbsolutePosSlot',
                         :value_label => 'Abs. % sum, pos+slot adj',
                         :list => @draft_helper.data_manager.get_sorted_players_list_with_pos_adjustments_plus_slots }]
    render :partial => 'player_table'
  end

  def new
    @draft_helper = DraftHelper.new
    @league = League.find(params[:league_id])
    @setting_manager = @league.setting_manager
  end

  def edit
    @draft_helper = DraftHelper.find(params[:id])
    authorize! :update, @draft_helper
  end

  def create
    if(League.find(params[:league_id]).draft_helper)
      redirect_to draft_helper_path(League.find(params[:league_id]).draft_helper)
    else
      @draft_helper = DraftHelper.new
      @draft_helper.user = current_user
      @draft_helper.league = League.find(params[:league_id])

      if @draft_helper.save
        redirect_to draft_helper_path(@draft_helper)
      else
        render 'new'
      end
    end
  end

  def destroy
    @league = League.find(params[:id])
    authorize! :destroy, @league

    @league.destroy

    redirect_to leagues_path
  end

  private
  def draft_helper_params
    params.require(:draft_helper).permit()
  end
end
