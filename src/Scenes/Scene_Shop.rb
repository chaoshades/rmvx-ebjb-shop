#==============================================================================
# ** Scene_Shop
#------------------------------------------------------------------------------
#  This class performs shop screen processing.
#==============================================================================

class Scene_Shop < Scene_Base
  include EBJB
  
  #//////////////////////////////////////////////////////////////////////////
  # * Constructors
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Object Initialization
  #     menu_index : command cursor's initial position
  #--------------------------------------------------------------------------
  def initialize(menu_index = 0)
    @menu_index = menu_index
  end
  
  #//////////////////////////////////////////////////////////////////////////
  # * Public Methods
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Start processing
  #--------------------------------------------------------------------------
  def start
    super
    create_menu_background()

    if SHOP_CONFIG::IMAGE_BG != ""
      @bg = Sprite.new
      @bg.bitmap = Cache.picture(SHOP_CONFIG::IMAGE_BG)
      @bg.opacity = SHOP_CONFIG::IMAGE_BG_OPACITY
    end
    
    @help_window = Window_Info_Help.new(0, 384, 640, 96, nil)
    @help_window.visible = false
    @gold_window = Window_ShopGold.new(440, 0, 200, 56)
    @gold_window.visible = true
    @shop_name_window = Window_ShopName.new(0, 0, 440, 56, $game_temp.shop_name)
    @shop_name_window.visible = true
    @equip_details_window = Window_EquipDetails.new(0, 384, 640, 96, nil)
    @equip_details_window.visible = false
    @item_details_window = Window_ItemDetails.new(0, 384, 640, 96, nil)
    @item_details_window.visible = false
    
    # Specify where are stored the characters to show in the shop
    characters = []
    characters.concat($game_party.members)
    # Optional (if you have other party members which aren't in the $game_party
    #           you can add them here)
    # ex.: characters.concat($game_party.other_members)
    
    @status_window = Window_ShopStatus.new(0, 56, 240, 328, characters)
    @status_window.visible = false
    @status_window.active = false
    @transaction_window = Window_Transaction.new(240, 328, 400, 56, nil, nil)
    @transaction_window.visible = false  
    
    @buy_window = Window_ShopBuy.new(240, 56, 400, 272, goods_to_items($game_temp.shop_goods))
    @buy_window.active = false
    @buy_window.visible = false
    @buy_window.help_window = @help_window
    
    @sell_window = Window_ShopSell.new(240, 56, 400, 272, $game_party.items)
    @sell_window.active = false
    @sell_window.visible = false
    @sell_window.help_window = @help_window
        
    create_command_window()
    @confirm_buy_window = create_confirmation_window(Vocab::confirm_buy_text)
    @confirm_sell_window = create_confirmation_window(Vocab::confirm_sell_text) 
    
    [@help_window, @gold_window, @shop_name_window, @status_window,
     @equip_details_window, @item_details_window, @confirm_buy_window, @confirm_sell_window,
     @command_window, @buy_window, @sell_window, @transaction_window].each{
      |w| w.opacity = SHOP_CONFIG::WINDOW_OPACITY;
          w.back_opacity = SHOP_CONFIG::WINDOW_BACK_OPACITY
    }
  end
  
  #--------------------------------------------------------------------------
  # * Termination Processing
  #--------------------------------------------------------------------------
  def terminate
    super
    dispose_menu_background

    unless @bg.nil?
      @bg.bitmap.dispose
      @bg.dispose
    end
    @help_window.dispose if @help_window != nil
    @gold_window.dispose if @gold_window != nil
    @shop_name_window.dispose if @shop_name_window != nil
    @status_window.dispose if @status_window != nil
    @item_details_window.dispose if @item_details_window != nil
    @equip_details_window.dispose if @equip_details_window != nil
    
    @confirm_buy_window.dispose if @confirm_buy_window != nil
    @confirm_sell_window.dispose if @confirm_sell_window != nil
    @command_window.dispose if @command_window != nil
    @buy_window.dispose if @buy_window != nil
    @sell_window.dispose if @sell_window != nil
    @transaction_window.dispose if @transaction_window != nil
  end
  
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update
    super
    update_menu_background
    
    @help_window.update
    @gold_window.update
    @shop_name_window.update
    @status_window.update
    @item_details_window.update
    @equip_details_window.update
    
    @confirm_buy_window.update
    @confirm_sell_window.update
    @command_window.update
    @buy_window.update
    @sell_window.update
    @transaction_window.update
    
    if @command_window.active
      update_command_selection()
    elsif @buy_window.active
      update_buy_selection()
    elsif @sell_window.active && @sell_window.selected_item == nil
      update_empty_sell_selection()
    elsif @sell_window.active
      update_sell_selection()
    elsif @confirm_buy_window.active
      update_buy_action()
    elsif @confirm_sell_window.active
      update_sell_action()
    end
  end
  
  #//////////////////////////////////////////////////////////////////////////
  # * Private Methods
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Create Command Window
  #--------------------------------------------------------------------------
  def create_command_window()
    s1 = Vocab::ShopBuy
    s2 = Vocab::ShopSell
    s3 = $data_system.terms.equip
    s4 = Vocab::ShopCancel
    @command_window = Window_Command.new(640, [s1, s2, s3, s4], 4)
    @command_window.index = @menu_index
    @command_window.y = 56
    if $game_temp.shop_purchase_only
      @command_window.draw_item(1, false)
    end
  end
  private :create_command_window
  
  #--------------------------------------------------------------------------
  # * Create Confirmation Window
  #--------------------------------------------------------------------------
  def create_confirmation_window(text)
    confirm = Window_Confirmation.new(220, 212, 200, text, 
              Vocab::confirm_yes_text, Vocab::confirm_no_text)
    confirm.active = false
    confirm.visible = false
    
    return confirm
  end
  private :create_confirmation_window
  
  #--------------------------------------------------------------------------
  # * Update the numeric up down
  #     isUp   : true to call the up operation, else false for the down operation
  #     window : window containing the numeric up down
  #-------------------------------------------------------------------------- 
  def update_number_select(isUp, window)
    window.update_number_select(isUp)
  end
  private :update_number_select
  
  #--------------------------------------------------------------------------
  # * Update Item stats
  #     item : item object
  #-------------------------------------------------------------------------- 
  def update_item_stats(item)
    @status_window.window_item_update(item)
    
    if item.is_a?(RPG::Item)
      if @buy_window.active
        @buy_window.detail_window = @item_details_window
      elsif @sell_window.active
        @sell_window.detail_window = @item_details_window
      end
      #@item_details_window.window_update(item)
    else
      if @buy_window.active
        @buy_window.detail_window = @equip_details_window
      elsif @sell_window.active
        @sell_window.detail_window = @equip_details_window
      end
      #@equip_details_window.winow_update(item)
    end
  end
  private :update_item_stats
  
  #--------------------------------------------------------------------------
  # * Update character selection
  #     isUp : true to do a pageup, else false for a pagedown of the characters
  #-------------------------------------------------------------------------- 
  def update_character_select(isUp)
    if isUp
      @status_window.cursor_pageup()
    else      
      @status_window.cursor_pagedown()
    end
  end
  private :update_character_select
  
  #--------------------------------------------------------------------------
  # * Update transaction
  #     shopItems : ShopItem objects list
  #-------------------------------------------------------------------------- 
  def update_transaction(shopItems)
    total = 0
    for shopItem in shopItems
      total += shopItem.item.price * shopItem.quantity
    end
    
    @transaction_window.window_update(@buy_window.active, total)
  end
  private :update_transaction
  
  #--------------------------------------------------------------------------
  # * Update Shop Windows
  #-------------------------------------------------------------------------- 
  def update_shop_windows()
    @gold_window.window_update()
    @transaction_window.window_update(nil, nil)
    @buy_window.window_update(goods_to_items($game_temp.shop_goods))
    @buy_window.update_items_activity(@transaction_window.difference)
    @sell_window.window_update($game_party.items)
    if @buy_window.active
      window = @buy_window
    else
      window = @sell_window
    end
    if window.selected_item != nil
      update_item_stats(window.selected_item.item)
    else
      # Position the cursor on the last item that is available
      window.index = window.index == 0 ? 0 : window.ucShopItemsList.size-1
      update_item_stats(nil) 
    end
  end
  private :update_shop_windows
  
  #--------------------------------------------------------------------------
  # * Converts shop goods to items
  #     goods : goods list
  #--------------------------------------------------------------------------
  def goods_to_items(goods)
    items = []
    for goods_item in goods
        case goods_item[0]
        when 0
          item = $data_items[goods_item[1]]
        when 1
          item = $data_weapons[goods_item[1]]
        when 2
          item = $data_armors[goods_item[1]]
        end
        if item != nil
          items.push(item)
        end
      end
    return items
  end
  private :goods_to_items
  
  #//////////////////////////////////////////////////////////////////////////
  # * Scene input management methods
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Update Command Selection
  #--------------------------------------------------------------------------
  def update_command_selection()
    if Input.trigger?(Input::B)
      Sound.play_cancel
      quit_command()
    elsif Input.trigger?(Input::C)
      case @command_window.index
      when 0  # Buy
        Sound.play_decision
        buy_command()
        update_item_stats(@buy_window.selected_item.item)
        @buy_window.update_items_activity($game_party.gold)
      when 1  # Sell
        if $game_temp.shop_purchase_only
          Sound.play_buzzer
        else
          Sound.play_decision
          sell_command()
          if @sell_window.selected_item != nil
            update_item_stats(@sell_window.selected_item.item)
          else
            update_item_stats(nil) 
          end
        end
      when 2 # Equip
        Sound.play_decision
        equip_command()
      when 3 # Quit
        Sound.play_decision
        quit_command()
      end
    end
  end
  private :update_command_selection
  
  #--------------------------------------------------------------------------
  # * Update Buy Item Selection
  #--------------------------------------------------------------------------
  def update_buy_selection()
    item = @buy_window.selected_item.item
    
    if Input.trigger?(Input::B)
      Sound.play_cancel
      cancel_command()
    
    elsif Input.repeat?(Input::DOWN) || Input.repeat?(Input::UP)
      update_item_stats(item)
    
    elsif Input.repeat?(Input::Y) || Input.repeat?(Input::Z)
      update_character_select(Input.press?(Input::Z))
      
    elsif Input.repeat?(Input::RIGHT) || Input.repeat?(Input::LEFT)
      if !@buy_window.selected_item.active && (Input.press?(Input::RIGHT) ||
         (Input.press?(Input::LEFT) && @buy_window.selected_item.is_min_number?))
        Sound.play_buzzer
      elsif (Input.press?(Input::RIGHT) && !@buy_window.selected_item.is_max_number?) ||
            (Input.press?(Input::LEFT) && !@buy_window.selected_item.is_min_number?)
          Sound.play_cursor
          update_number_select(Input.press?(Input::RIGHT), @buy_window)
          update_transaction(@buy_window.selected_items)
          @buy_window.update_items_activity(@transaction_window.difference)
      end
    
    elsif Input.trigger?(Input::C)
      if (@buy_window.selected_items.size == 0)
        Sound.play_buzzer
      else
        Sound.play_decision
        @confirm_buy_window.show()
        @buy_window.active=false
      end
    end

  end
  private :update_buy_selection
  
  #--------------------------------------------------------------------------
  # * Update Buy Action
  #--------------------------------------------------------------------------
  def update_buy_action()
    if Input.trigger?(Input::B)
      Sound.play_cancel
      @confirm_buy_window.hide()
      @buy_window.active=true
    elsif Input.trigger?(Input::C)
      case @confirm_buy_window.index
      when 0
        Sound.play_shop
        buy_action(@buy_window.selected_items)
        @confirm_buy_window.hide()
        @buy_window.active=true
        update_shop_windows()
      when 1
        Sound.play_cancel
        @confirm_buy_window.hide()
        @buy_window.active=true
      end
    end
  end
  
  #--------------------------------------------------------------------------
  # * Update Sell Item Selection
  #--------------------------------------------------------------------------
  def update_sell_selection()
    item = @sell_window.selected_item.item

    if Input.trigger?(Input::B)
      Sound.play_cancel
      cancel_command()
        
    elsif Input.repeat?(Input::DOWN) || Input.repeat?(Input::UP)
      update_item_stats(item)
        
    elsif Input.repeat?(Input::Y) || Input.repeat?(Input::Z)
      update_character_select(Input.press?(Input::Z))
        
    elsif Input.repeat?(Input::RIGHT) || Input.repeat?(Input::LEFT)
      if (Input.press?(Input::RIGHT) && !@sell_window.selected_item.is_max_number?) ||
          (Input.press?(Input::LEFT) && !@sell_window.selected_item.is_min_number?)
        Sound.play_cursor
        update_number_select(Input.press?(Input::RIGHT), @sell_window)
        update_transaction(@sell_window.selected_items)
      end
        
    elsif Input.trigger?(Input::C)
      if (@sell_window.selected_items.size == 0)
        Sound.play_buzzer
      else
        Sound.play_decision
        @confirm_sell_window.show()
        @sell_window.active=false
      end
    end
  end
  private :update_sell_selection
  
  #--------------------------------------------------------------------------
  # * Update Empty Sell Item Selection
  #--------------------------------------------------------------------------
  def update_empty_sell_selection()
    if Input.trigger?(Input::B)
      Sound.play_cancel
      cancel_command()
    elsif Input.repeat?(Input::Y) || Input.repeat?(Input::Z)
      update_character_select(Input.press?(Input::Z))
    elsif Input.trigger?(Input::C)
      Sound.play_buzzer
    end
   end
  private :update_sell_selection 
  
  #--------------------------------------------------------------------------
  # * Update Sell Action
  #--------------------------------------------------------------------------
  def update_sell_action()
    if Input.trigger?(Input::B)
      Sound.play_cancel
      @confirm_sell_window.hide()
      @sell_window.active=true
    elsif Input.trigger?(Input::C)
      case @confirm_sell_window.index
      when 0
        Sound.play_shop
        sell_action(@sell_window.selected_items)
        @confirm_sell_window.hide()
        @sell_window.active=true
        update_shop_windows()
      when 1
        Sound.play_cancel
        @confirm_sell_window.hide()
        @sell_window.active=true
      end
    end
  end
  
  #//////////////////////////////////////////////////////////////////////////
  # * Scene Commands
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Cancel command
  #--------------------------------------------------------------------------
  def cancel_command()
    @command_window.active = true
    @command_window.visible = true
    @buy_window.active = false
    @buy_window.visible = false
    @buy_window.reset_number_select()
    @buy_window.index = 0
    @sell_window.active = false
    @sell_window.visible = false
    @sell_window.reset_number_select()
    @sell_window.index = 0
    @status_window.visible = false
    @status_window.window_item_update(nil)
    @item_details_window.window_update(nil)
    @item_details_window.visible = false
    @help_window.window_update("")
    @help_window.visible = false
    @transaction_window.visible = false
    @transaction_window.window_update(nil, nil)
  end
  private :cancel_command
  
  #--------------------------------------------------------------------------
  # * Quit command
  #--------------------------------------------------------------------------
  def quit_command()
    $game_temp.shop_name = nil
    $scene = Scene_Map.new
  end
  private :quit_command
  
  #--------------------------------------------------------------------------
  # * Equip command
  #--------------------------------------------------------------------------
  def equip_command()
    $scene = Scene_Equip.new(0, 0, 2)
  end
  private :equip_command
  
  #--------------------------------------------------------------------------
  # * Buy command
  #--------------------------------------------------------------------------
  def buy_command()
    @status_window.index = 0
    @command_window.active = false
    @command_window.visible = false
    @buy_window.active = true
    @buy_window.call_update_help()
    @buy_window.visible = true
    @status_window.visible = true
    @help_window.visible = true
    @transaction_window.visible = true
  end
  private :buy_command
  
  #--------------------------------------------------------------------------
  # * Sell command
  #--------------------------------------------------------------------------
  def sell_command()
    @status_window.index = 0
    @command_window.active = false
    @command_window.visible = false
    @sell_window.active = true
    @sell_window.call_update_help()
    @sell_window.visible = true
    @status_window.visible = true
    @help_window.visible = true
    @transaction_window.visible = true
  end
  private :sell_command

  #//////////////////////////////////////////////////////////////////////////
  # * Scene Actions
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Buy action
  #     items : selected ShopItems list
  #--------------------------------------------------------------------------
  def buy_action(shopItems)
    for shop_item in shopItems
      $game_party.lose_gold(shop_item.item.price * shop_item.quantity)
      $game_party.gain_item(shop_item.item, shop_item.quantity)
    end
  end
  private :buy_action

  #--------------------------------------------------------------------------
  # * Sell action
  #     items : selected ShopItems list
  #--------------------------------------------------------------------------
  def sell_action(shopItems)
    for shop_item in shopItems
      $game_party.gain_gold(shop_item.item.price * shop_item.quantity)
      $game_party.lose_item(shop_item.item, shop_item.quantity)
    end
  end
  private :sell_action
  
end
