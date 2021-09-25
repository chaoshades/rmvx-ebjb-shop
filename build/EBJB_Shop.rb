################################################################################
#                           EBJB Shop - EBJB_Shop                     #   VX   #
#                          Last Update: 2012/03/16                    ##########
#                         Creation Date: 2011/06/25                            #
#                          Author : GoldenHades                                #
#     Source :                                                                 #
#     http://www.google.com                                                    #
#------------------------------------------------------------------------------#
#  Contains custom scripts adding new features to the Shop in your game.       #
#==============================================================================#
#                         ** Instructions For Usage **                         #
#  There are settings that can be configured in the Shop_Config class. For     #
#  more info on what and how to adjust these settings, see the documentation   #
#  in the class.                                                               #
#==============================================================================#
#                                ** Examples **                                #
#  See the documentation in each classes.                                      #
#==============================================================================#
#                           ** Installation Notes **                           #
#  Copy this script in the Materials section                                   #
#==============================================================================#
#                             ** Compatibility **                              #
#  Alias: Game_Temp - initialize                                               #
#  Alias: Scene_Equip - initialize, return_scene                               #
################################################################################

$imported = {} if $imported == nil
$imported["EBJB_Shop"] = true

#==============================================================================
# ** SHOP_CONFIG
#------------------------------------------------------------------------------
#  Contains the Shop configuration
#==============================================================================

module EBJB
  module SHOP_CONFIG
    
    # Background image filename, it must be in folder Pictures
    IMAGE_BG = ""
    # Opacity for background image
    IMAGE_BG_OPACITY = 255
    # All windows opacity
    WINDOW_OPACITY = 255
    WINDOW_BACK_OPACITY = 200
        
    #------------------------------------------------------------------------
    # Window Transaction related
    #------------------------------------------------------------------------
    
    # Symbol for buying
    BUYING_SYMBOL = "-"
    # Symbol for selling
    SELLING_SYMBOL = "+"
    
    #------------------------------------------------------------------------
    # Window Gold related
    #------------------------------------------------------------------------
    
    # Icon for GOLD
    ICON_GOLD = 147
    
    #------------------------------------------------------------------------
    # Window Shop related
    #------------------------------------------------------------------------
    
    # Max number of items allowed to buy or sell in one time
    MAX_ITEM = 99
    # Pattern used to show the item desired quantity
    ITEM_NUMBER_PATTERN = "×%d"
    
    #------------------------------------------------------------------------
    # Window Shop Status related
    #------------------------------------------------------------------------
    
    # Symbol when a stat is higher with the new item
    POWERUP_SYMBOL = "+" #"▲"
    # Symbol when a stat is lower with the new item
    POWERDOWN_SYMBOL = "-" #"▼"
    
  end
end

#==============================================================================
# ** Game_Temp
#------------------------------------------------------------------------------
#  This class handles temporary data that is not included with save data.
# The instance of this class is referenced by $game_temp.
#==============================================================================

class Game_Temp
  
  #//////////////////////////////////////////////////////////////////////////
  # * Attributes
  #//////////////////////////////////////////////////////////////////////////
  
  # Shop name
  attr_accessor :shop_name
  
  #//////////////////////////////////////////////////////////////////////////
  # * Constructors
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Alias initialize
  #--------------------------------------------------------------------------
  alias initialize_ebjb initialize unless $@
  def initialize
    initialize_ebjb()
    @shop_name = nil
  end
  
end

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

#==============================================================================
# ** Scene_Equip
#------------------------------------------------------------------------------
#  This class performs the equipment screen processing.
#==============================================================================

class Scene_Equip < Scene_Base
  
  #//////////////////////////////////////////////////////////////////////////
  # * Constructors
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Alias initialize
  #--------------------------------------------------------------------------
  alias initialize_ebjb initialize unless $@
  def initialize(actor_index = 0, equip_index = 0, shop_menu_index = nil)
    initialize_ebjb(actor_index, equip_index)
    @shop_menu_index = shop_menu_index
  end
  
  #//////////////////////////////////////////////////////////////////////////
  # * Public Methods
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # Alias return_scene
  #--------------------------------------------------------------------------
  alias return_scene_ebjb return_scene unless $@
  def return_scene
    if @shop_menu_index != nil 
      $scene = Scene_Shop.new(@shop_menu_index)
    else
      return_scene_ebjb()
    end
  end
  
end

#==============================================================================
# ** Font
#------------------------------------------------------------------------------
#  Contains the different fonts
#==============================================================================

class Font
  
  #//////////////////////////////////////////////////////////////////////////
  # * Public Methods
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Get Shop Possession Label Font
  #--------------------------------------------------------------------------
  def self.shop_possess_font
    f = Font.new()
    f.color = Color.shop_possess_color()
    f.bold = true
    return f
  end
  
  #--------------------------------------------------------------------------
  # * Get Compare Stats Font
  #--------------------------------------------------------------------------
  def self.compare_stats_font
    f = Font.new()
    f.size = 12
    return f
  end
  
  #--------------------------------------------------------------------------
  # * Get Item Details Stats Font
  #--------------------------------------------------------------------------
  def self.item_details_stats_font
    f = Font.new()
    f.size = 12
    return f
  end
  
  #--------------------------------------------------------------------------
  # * Get Item Details Plus States Font
  #--------------------------------------------------------------------------
  def self.item_details_plus_states_font
    f = Font.new()
    f.color = Color.power_up_color()
    f.size = 20
    f.bold = true
    return f
  end
  
  #--------------------------------------------------------------------------
  # * Get Item Details Minus States Font
  #--------------------------------------------------------------------------
  def self.item_details_minus_states_font
    f = Font.new()
    f.color = Color.power_down_color()
    f.size = 20
    f.bold = true
    return f
  end
  
end

#==============================================================================
# ** Color
#------------------------------------------------------------------------------
#  Contains the different colors
#==============================================================================

class Color
  
  #--------------------------------------------------------------------------
  # * Get Shop Possession Color
  #--------------------------------------------------------------------------
  def self.shop_possess_color
    return text_color(1)
  end
  
  #--------------------------------------------------------------------------
  # * Get Sell Transaction Color
  #--------------------------------------------------------------------------
  def self.sell_transaction_color
    return text_color(24)
  end
  
  #--------------------------------------------------------------------------
  # * Get Buy Transaction Color
  #--------------------------------------------------------------------------
  def self.buy_transaction_color
    return text_color(25)
  end
  
end
#==============================================================================
# ** Vocab
#------------------------------------------------------------------------------
#  This module defines terms and messages. It defines some data as constant
# variables. Terms in the database are obtained from $data_system.
#==============================================================================

module Vocab

  #//////////////////////////////////////////////////////////////////////////
  # * Public Methods
  #//////////////////////////////////////////////////////////////////////////
  
  #//////////////////////////////////////////////////////////////////////////
  # * Stats Parameters related
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Get HP Label
  #--------------------------------------------------------------------------
  def self.hp_label
    return self.hp
  end
  
  #--------------------------------------------------------------------------
  # * Get MP Label
  #--------------------------------------------------------------------------
  def self.mp_label
    return self.mp
  end
  
  #--------------------------------------------------------------------------
  # * Get ATK Label
  #--------------------------------------------------------------------------
  def self.atk_label
    return self.atk
  end
  
  #--------------------------------------------------------------------------
  # * Get DEF Label
  #--------------------------------------------------------------------------
  def self.def_label
    return self.def
  end
  
  #--------------------------------------------------------------------------
  # * Get SPI Label
  #--------------------------------------------------------------------------
  def self.spi_label
    return self.spi
  end
  
  #--------------------------------------------------------------------------
  # * Get AGI Label
  #--------------------------------------------------------------------------
  def self.agi_label
    return self.agi
  end
  
  #--------------------------------------------------------------------------
  # * Get EVA Label
  #--------------------------------------------------------------------------
  def self.eva_label
    return "EVA"
  end
  
  #--------------------------------------------------------------------------
  # * Get HIT Label
  #--------------------------------------------------------------------------
  def self.hit_label
    return "HIT"
  end
  
  #//////////////////////////////////////////////////////////////////////////
  # * Transaction Window related
  #//////////////////////////////////////////////////////////////////////////

  #--------------------------------------------------------------------------
  # * Get Total of the transaction text
  #--------------------------------------------------------------------------
  def self.transaction_total_text
    return "Total"
  end
  
  #--------------------------------------------------------------------------
  # * Get Difference of the transaction Label
  #--------------------------------------------------------------------------
  def self.transaction_diff_text
    return "Difference"
  end
  
  #//////////////////////////////////////////////////////////////////////////
  # * Shop Status Window related
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Get Text to show when the new item is equivalent to the one already equipped
  #--------------------------------------------------------------------------
  def self.status_equivalent_text
    return "Equivalent"
  end
  
  #--------------------------------------------------------------------------
  # * Get Text to show the character can't equip an item
  #--------------------------------------------------------------------------
  def self.status_cantequip_text
    return "Can't equip"
  end
  
  #--------------------------------------------------------------------------
  # * Get Text to show when the new equipment is already equipped
  #--------------------------------------------------------------------------
  def self.status_equipped_text
    return "Equipped"
  end

  #//////////////////////////////////////////////////////////////////////////
  # * Details Window related
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Get Label to show for the Elements list
  #--------------------------------------------------------------------------
  def self.elements_label
    return "ELEMENTS"
  end
  
  #--------------------------------------------------------------------------
  # * Get Label to show for the States list
  #--------------------------------------------------------------------------
  def self.states_label
    return "STATES"
  end
  
  #--------------------------------------------------------------------------
  # * Get Label to show for the Stats
  #--------------------------------------------------------------------------
  def self.stats_label
    return "STATS"
  end
  
  #--------------------------------------------------------------------------
  # * Get Label to show for the Recovery effect
  #--------------------------------------------------------------------------
  def self.recovery_label
    return "RECOVERY"
  end
  
  #--------------------------------------------------------------------------
  # * Get Label to show for the Damage effect
  #--------------------------------------------------------------------------
  def self.damage_label
    return "DAMAGE"
  end
  
  #--------------------------------------------------------------------------
  # * Get Label to show for the Scope list
  #--------------------------------------------------------------------------
  def self.scopes_label
    return "DAMAGE"
  end
  
  #--------------------------------------------------------------------------
  # * Get Label to show for the Bonus list
  #--------------------------------------------------------------------------
  def self.bonus_label
    return "BONUS"
  end
  
  #//////////////////////////////////////////////////////////////////////////
  # * Confirmation Window related
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Get Text to show in the confirmation window when buying
  #--------------------------------------------------------------------------
  def self.confirm_buy_text
    return "Complete transaction ?"
  end
  
  #--------------------------------------------------------------------------
  # * Get Text to show in the confirmation window when selling
  #--------------------------------------------------------------------------
  def self.confirm_sell_text
    return "Complete transaction ?"
  end
  
  #--------------------------------------------------------------------------
  # * Get Text to show Yes command of the confirmation window
  #--------------------------------------------------------------------------
  def self.confirm_yes_text
    return "Yes"
  end
  
  #--------------------------------------------------------------------------
  # * Get Text to show No command of the confirmation window
  #--------------------------------------------------------------------------
  def self.confirm_no_text
    return "No"
  end

end

#==============================================================================
# ** Window_ShopGold
#------------------------------------------------------------------------------
#  This window displays the amount of gold.
#==============================================================================

class Window_ShopGold < Window_Base
  include EBJB
  
  #//////////////////////////////////////////////////////////////////////////
  # * Attributes
  #//////////////////////////////////////////////////////////////////////////
  
  # UCLabelIcon control for the party gold
  attr_reader :ucGold
  
  #//////////////////////////////////////////////////////////////////////////
  # * Constructors
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Object Initialization
  #     x : window X coordinate
  #     y : window Y coordinate
  #     width  : window width
  #     height : window height
  #--------------------------------------------------------------------------
  def initialize(x, y, width, height)
    super(x, y, width, height)
    
    @ucGold = UCLabelIcon.new(self, Rect.new(0,0,100,WLH), Rect.new(110,0,WLH,WLH),
                              "", SHOP_CONFIG::ICON_GOLD)
    @ucGold.cLabel.align = 2
    window_update()
  end
  
  #//////////////////////////////////////////////////////////////////////////
  # * Public Methods
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh()
    self.contents.clear
    @ucGold.draw()
  end
  
  #--------------------------------------------------------------------------
  # * Update
  #--------------------------------------------------------------------------
  def window_update()
    @ucGold.cLabel.text = $game_party.gold
    refresh()
  end
  
end

#==============================================================================
# ** Window_Transaction
#------------------------------------------------------------------------------
#  This window displays the total and the difference for a shopping transaction
#==============================================================================

class Window_Transaction < Window_Base
  include EBJB
  
  #//////////////////////////////////////////////////////////////////////////
  # * Attributes
  #//////////////////////////////////////////////////////////////////////////
  
  # UCLabelValue for the total of the transaction
  attr_reader :ucTotal
  # UCLabelValue for the difference of the transaction
  attr_reader :ucDifference
  
  #//////////////////////////////////////////////////////////////////////////
  # * Properties
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Get the difference
  #--------------------------------------------------------------------------
  # GET
  def difference
    return @ucDifference.cValue.text.to_i
  end
  
  #//////////////////////////////////////////////////////////////////////////
  # * Constructors
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Object Initialization
  #     x : window X coordinate
  #     y : window Y coordinate
  #     width  : window width
  #     height : window height
  #     isBuying : true if it is a buying transaction, else false
  #     total : total of the transaction
  #--------------------------------------------------------------------------
  def initialize(x, y, width, height, isBuying, total)
    super(x, y, width, height)
    @ucTotal = UCLabelValue.new(self, Rect.new(0,0,65,WLH), 
                                Rect.new(70,0,100,WLH),
                                Vocab::transaction_total_text, 0)
    @ucDifference = UCLabelValue.new(self, Rect.new(190,0,75,WLH), 
                                     Rect.new(265,0,100,WLH),
                                     Vocab::transaction_diff_text, 0)
    @ucTotal.cValue.align = 2
    @ucDifference.cValue.align = 2
    window_update(isBuying, total)
  end
  
  #//////////////////////////////////////////////////////////////////////////
  # * Public Methods
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh()
    self.contents.clear
    @ucTotal.draw()
    @ucDifference.draw()
  end
  
  #--------------------------------------------------------------------------
  # * Update
  #     isBuying : true if it is a buying transaction, else false
  #     total : total of the transaction
  #--------------------------------------------------------------------------
  def window_update(isBuying, total)
    if isBuying != nil && total != nil && total > 0
      if isBuying
        @ucTotal.cValue.font.color = Color.buy_transaction_color
        difference = [$game_party.gold - total, 0].max
        symbol = SHOP_CONFIG::BUYING_SYMBOL
      else
        @ucTotal.cValue.font.color = Color.sell_transaction_color
        difference = [$game_party.gold + total, 9999999].min
        symbol = SHOP_CONFIG::SELLING_SYMBOL
      end
    else
      @ucTotal.cValue.font.color = Color.normal_color
      total = 0
      difference = $game_party.gold
      symbol = ""
    end

    @ucTotal.cValue.text = symbol + total.to_s
    @ucDifference.cValue.text = difference
    refresh()
  end
  
end

#==============================================================================
# ** Window_Shop
#------------------------------------------------------------------------------
#  This window displays the items for a shop screen.
#==============================================================================

class Window_Shop < Window_Selectable
  include EBJB
  
  #//////////////////////////////////////////////////////////////////////////
  # * Attributes
  #//////////////////////////////////////////////////////////////////////////
  
  # Array of UCShopItem for every item of the shop
  attr_reader :ucShopItemsList
  
  #//////////////////////////////////////////////////////////////////////////
  # * Properties
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Get the current ShopItem
  #--------------------------------------------------------------------------
  # GET
  def selected_item
    return (self.index < 0 ? nil : @ucShopItemsList[self.index])
  end
  
  #--------------------------------------------------------------------------
  # * Get the selected ShopItems (number > 0 or min)
  #--------------------------------------------------------------------------
  # GET
  def selected_items
    itemArray = []
    for shopItem in @ucShopItemsList
      if !shopItem.is_min_number?
        itemArray.push(shopItem)
      end
    end
    return itemArray
  end
  
  #//////////////////////////////////////////////////////////////////////////
  # * Constructors
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Object Initialization
  #     x : window X coordinate
  #     y : window Y coordinate
  #     width  : window width
  #     height : window height
  #     item : list of the items
  #--------------------------------------------------------------------------
  def initialize(x, y, width, height, items)
    super(x, y, width, height)
    @ucShopItemsList = []
    window_update(items)
    self.index = 0
  end
  
  #//////////////////////////////////////////////////////////////////////////
  # * Public Methods
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh()
    self.contents.clear
    @ucShopItemsList.each() { |shopItem| shopItem.draw() }
  end
  
  #--------------------------------------------------------------------------
  # * Update
  #--------------------------------------------------------------------------
  def window_update(shop_items)
    @data = []
    if shop_items != nil
      for shop_item in shop_items
        if shop_item != nil
          @data.push(shop_item)
        end
      end
      @item_max = @data.size
      create_contents()
      @ucShopItemsList.clear()
      for i in 0..@item_max-1
        @ucShopItemsList.push(create_item(i))
      end
    end
    refresh()
  end
  
  #--------------------------------------------------------------------------
  # * Update the numeric up down
  #--------------------------------------------------------------------------
  def update_number_select(isUp)
    if isUp
      selected_item.ucItemNumber.up()
    else
      selected_item.ucItemNumber.down()
    end
    refresh()
  end
  
  #--------------------------------------------------------------------------
  # * Update Help Text
  #--------------------------------------------------------------------------
  def update_help
    if selected_item != nil
      @help_window.window_update(selected_item.item.description)
    else
      @help_window.window_update("")
    end
  end
  
  #--------------------------------------------------------------------------
  # * Update Detail Window
  #--------------------------------------------------------------------------
  def update_detail
    if selected_item != nil
      @detail_window.window_update(selected_item.item)
    else
      @detail_window.window_update(nil)
    end
  end
  
  #--------------------------------------------------------------------------
  # * Determine if help/detail window can be switched
  #--------------------------------------------------------------------------
  def is_switchable
    return selected_item != nil && 
           ((selected_item.item.is_a?(RPG::Item) && detail_window.is_a?(Window_ItemDetails)) ||
           (!selected_item.item.is_a?(RPG::Item) && detail_window.is_a?(Window_EquipDetails)))
  end
  
  #--------------------------------------------------------------------------
  # * Reset the numeric up down controls
  #--------------------------------------------------------------------------
  def reset_number_select()
    @ucShopItemsList.each() { |shopItem| shopItem.ucItemNumber.reset() }
    refresh()
  end
  
  #--------------------------------------------------------------------------
  # * Update ShopItems activity
  #--------------------------------------------------------------------------
  def update_items_activity(party_gold)
    @ucShopItemsList.each() { |shopItem| shopItem.active = 
                              shopItem.item.price <= party_gold &&
                              shopItem.inventory_quantity < SHOP_CONFIG::MAX_ITEM}
    refresh()
  end
  
  #//////////////////////////////////////////////////////////////////////////
  # * Private Methods
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Create an item for the ShopItems list (contents are defined by the subclasses)
  #     index : item index
  #--------------------------------------------------------------------------
  def create_item(index)
  end
  private :create_item
  
end

#==============================================================================
# ** Window_ShopBuy
#------------------------------------------------------------------------------
#  This window displays buyable goods on the shop screen.
#==============================================================================

class Window_ShopBuy < Window_Shop
  include EBJB
  
  #//////////////////////////////////////////////////////////////////////////
  # * Private Methods
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Create an item for the ShopItems list 
  #     index : item index
  #--------------------------------------------------------------------------
  def create_item(index)
    item = @data[index]
    rect = item_rect(index, true)
    
    shopItem = UCShopItem.new(self, item, rect,
                              SHOP_CONFIG::ITEM_NUMBER_PATTERN)
                              
    shopItem.cItemPrice.align = 2 
    shopItem.cItemPossess.align = 2 
    shopItem.cItemPossess.font = Font.shop_possess_font
    shopItem.ucItemNumber.cLabelNumber.align = 2
    shopItem.ucItemNumber.min = 0
    shopItem.ucItemNumber.max = SHOP_CONFIG::MAX_ITEM - shopItem.inventory_quantity
    return shopItem
  end
  private :create_item
  
end

#==============================================================================
# ** Window_ShopSell
#------------------------------------------------------------------------------
#  This window displays items in possession for selling on the shop screen.
#==============================================================================

class Window_ShopSell < Window_Shop
  include EBJB
  
  #//////////////////////////////////////////////////////////////////////////
  # * Private Methods
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Create an item for the ShopItems list
  #     index : item index
  #--------------------------------------------------------------------------
  def create_item(index)
    item = @data[index]
    rect = item_rect(index, true)
    
    shopItem = UCShopItem.new(self, item, rect,
                              SHOP_CONFIG::ITEM_NUMBER_PATTERN)
                              
    shopItem.cItemPrice.align = 2
    shopItem.cItemPossess.align = 2 
    shopItem.cItemPossess.font = Font.shop_possess_font
    shopItem.ucItemNumber.cLabelNumber.align = 2
    shopItem.ucItemNumber.min = 0
    shopItem.ucItemNumber.max = shopItem.inventory_quantity
    return shopItem
  end
  private :create_item
  
end

#==============================================================================
# ** Window_ShopStatus
#------------------------------------------------------------------------------
#  This window displays the actor's equipment on the shop screen.
#==============================================================================

class Window_ShopStatus < Window_Selectable
  include EBJB
  
  #//////////////////////////////////////////////////////////////////////////
  # * Attributes
  #//////////////////////////////////////////////////////////////////////////
  
  # Array of UCShopStatus for every character of the party
  attr_reader :ucShopStatusList
  
  #//////////////////////////////////////////////////////////////////////////
  # * Properties
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Get the current ShopStatus
  #--------------------------------------------------------------------------
  def selected_status
    return @ucShopStatusList[self.index]
  end
  
  #//////////////////////////////////////////////////////////////////////////
  # * Constructors
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Object Initialization
  #     x : window X coordinate
  #     y : window Y coordinate
  #     width  : window width
  #     height : window height
  #     characters : characters list
  #--------------------------------------------------------------------------
  def initialize(x, y, width, height, characters)
    super(x, y, width, height, 32, 74, false)
    @ucShopStatusList = []
    window_update(characters)
    self.index = 0
  end
  
  #//////////////////////////////////////////////////////////////////////////
  # * Public Methods
  #//////////////////////////////////////////////////////////////////////////

  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh()
    self.contents.clear
    @ucShopStatusList.each() { |shopData| shopData.draw() }
  end

  #--------------------------------------------------------------------------
  # * Update
  #     characters : characters list
  #--------------------------------------------------------------------------
  def window_update(characters)
    @data = []
    if characters != nil
      for char in characters
        if char != nil
          @data.push(char)
        end
      end
      @item_max = @data.size
      create_contents()
      @ucShopStatusList.clear()
      for i in 0..@item_max-1
        @ucShopStatusList.push(create_item(i))
      end
    end
    refresh()
  end
  
  #--------------------------------------------------------------------------
  # * Update item
  #     newItem : item object
  #--------------------------------------------------------------------------
  def window_item_update(newItem)
    for i in 0 .. @item_max-1
      set_shopData_activity(@ucShopStatusList[i], false, false)
      if newItem != nil
        
        if @ucShopStatusList[i].actor.equippable?(newItem)
      
          equippedItem = get_equipped_item(newItem, @ucShopStatusList[i].actor)
          
          compareItem = ShopStatusCompare.new(newItem, equippedItem)
            
          if compareItem.is_same()
            @ucShopStatusList[i].cMsg.text = Vocab::status_equipped_text
            @ucShopStatusList[i].cMsg.font.color = Color.normal_color
            set_control_enabled(@ucShopStatusList[i].cMsg, true, true)
          elsif compareItem.is_equivalent()
            @ucShopStatusList[i].cMsg.text = Vocab::status_equivalent_text
            @ucShopStatusList[i].cMsg.font.color = Color.normal_color
            set_control_enabled(@ucShopStatusList[i].cMsg, true, true)
          else
            
            if compareItem.atkDifference != 0
              set_stat_value(@ucShopStatusList[i].ucAtkStat.cValue, compareItem.atkDifference)
              set_control_enabled(@ucShopStatusList[i].ucAtkStat, true, true)
            end
            
            if compareItem.defDifference != 0
              set_stat_value(@ucShopStatusList[i].ucDefStat.cValue, compareItem.defDifference)
              set_control_enabled(@ucShopStatusList[i].ucDefStat, true, true)
            end
            
            if compareItem.spiDifference != 0
              set_stat_value(@ucShopStatusList[i].ucSpiStat.cValue, compareItem.spiDifference)
              set_control_enabled(@ucShopStatusList[i].ucSpiStat, true, true)
            end
            
            if compareItem.agiDifference != 0
              set_stat_value(@ucShopStatusList[i].ucAgiStat.cValue, compareItem.agiDifference)
              set_control_enabled(@ucShopStatusList[i].ucAgiStat, true, true)
            end
            
            if compareItem.evaDifference != 0
              set_stat_value(@ucShopStatusList[i].ucEvaStat.cValue, compareItem.evaDifference)
              set_control_enabled(@ucShopStatusList[i].ucEvaStat, true, true)
            end
              
            if compareItem.hitDifference != 0
              set_stat_value(@ucShopStatusList[i].ucHitStat.cValue, compareItem.hitDifference)
              set_control_enabled(@ucShopStatusList[i].ucHitStat, true, true)
            end
          end
        else
          @ucShopStatusList[i].cMsg.text = Vocab::status_cantequip_text
          @ucShopStatusList[i].cMsg.font.color = Color.power_down_color
          set_control_enabled(@ucShopStatusList[i].cMsg, true, true)
        end       
      else
        @ucShopStatusList[i].cMsg.text = Vocab::status_cantequip_text
        @ucShopStatusList[i].cMsg.font.color = Color.power_down_color 
        set_control_enabled(@ucShopStatusList[i].cMsg, true, true)
      end  
    end
    refresh()
  end

  #//////////////////////////////////////////////////////////////////////////
  # * Private Methods
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Get the currently equipped item to compare with the new item
  #     newItem : New item to compare
  #     actor : Actor from which we get the equipped item
  #--------------------------------------------------------------------------
  def get_equipped_item(newItem, actor)
    equippedItem = nil
    if newItem.is_a?(RPG::Weapon)
      equippedItem = weaker_weapon(actor)
    #elsif actor.two_swords_style and @item.kind = 0
      #equippedItem = nil 
    elsif newItem.is_a?(RPG::Armor)
      equippedItem = get_equipped_armor(newItem.kind, actor)
    end
    return equippedItem
  end
  private :get_equipped_item
  
  #--------------------------------------------------------------------------
  # * Get the currently equipped armor
  #     kind : kind of the armor
  #     actor : Actor from which we get the equipped armor
  #--------------------------------------------------------------------------
  def get_equipped_armor(kind, actor)
    armor = nil
    case kind 
    when 0
      armor = $data_armors[actor.armor1_id]
    when 1
      armor = $data_armors[actor.armor2_id]
    when 2
      armor = $data_armors[actor.armor3_id]
    when 3
      armor = $data_armors[actor.armor4_id]
    end   
    return armor
  end
  private :get_equipped_armor
  
  #--------------------------------------------------------------------------
  # * Get Weaker Weapon Equipped by the Actor (for dual wielding)
  #     actor : actor
  #--------------------------------------------------------------------------
  def weaker_weapon(actor)
    if actor.two_swords_style
      weapon1 = actor.weapons[0]
      weapon2 = actor.weapons[1]
      if weapon1 == nil or weapon2 == nil
        return nil
      elsif weapon1.atk < weapon2.atk
        return weapon1
      else
        return weapon2
      end
    else
      return actor.weapons[0]
    end
  end
  private :weaker_weapon
  
  #--------------------------------------------------------------------------
  # * Update the stat value in the control
  #     control : control to set the value
  #     value : value to set in the control
  #--------------------------------------------------------------------------
  def set_stat_value(control, value)
    if value >= 0
      control.font.color = Color.power_up_color
      control.text = SHOP_CONFIG::POWERUP_SYMBOL + value.abs.to_s
    else
      control.font.color = Color.power_down_color
      control.text = SHOP_CONFIG::POWERDOWN_SYMBOL + value.abs.to_s
    end
  end
  private :set_stat_value
  
  #--------------------------------------------------------------------------
  # * Set the controls visibility/activity of a shopData object
  #     shopData : ShopData Object that contains the controls
  #     visible : control visibility
  #     active : control activity
  #--------------------------------------------------------------------------
  def set_shopData_activity(shopData, visible, active)
    set_control_enabled(shopData.cMsg, visible, active)
    set_control_enabled(shopData.ucAtkStat, visible, active)
    set_control_enabled(shopData.ucDefStat, visible, active)
    set_control_enabled(shopData.ucSpiStat, visible, active)
    set_control_enabled(shopData.ucAgiStat, visible, active)
    set_control_enabled(shopData.ucEvaStat, visible, active)
    set_control_enabled(shopData.ucHitStat, visible, active)
  end
  private :set_shopData_activity
  
  #--------------------------------------------------------------------------
  # * Enable the control
  #     shopData : ShopData Object that contains the controls
  #     visible : control visibility
  #     active : control activity
  #--------------------------------------------------------------------------
  def set_control_enabled(control, visible, active)
    control.active = active
    control.visible = visible
  end
  private :set_control_enabled
  
  #--------------------------------------------------------------------------
  # * Create an item for ShopStatusList
  #     index : item index
  #--------------------------------------------------------------------------
  def create_item(index)
    actor = @data[index]
    rect = item_rect(index)

    shopStatus = UCShopStatus.new(self, actor, rect)

    return shopStatus
  end
  private :create_item
  
end

#==============================================================================
# ** Window_ShopName
#------------------------------------------------------------------------------
#  This window displays the name of the shop.
#==============================================================================

class Window_ShopName < Window_Base
  include EBJB
  
  #//////////////////////////////////////////////////////////////////////////
  # * Attributes
  #//////////////////////////////////////////////////////////////////////////
  
  # Label control for the shop name
  attr_reader :cShopName
  
  #//////////////////////////////////////////////////////////////////////////
  # * Constructors
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Object Initialization
  #     x : window X coordinate
  #     y : window Y coordinate
  #     width  : window width
  #     height : window height
  #     shopName : Name of the shop
  #--------------------------------------------------------------------------
  def initialize(x, y, width, height, shopName)
    super(x, y, width, height)
    
    @cShopName = CLabel.new(self, Rect.new(0,0,410,WLH), "", 1, Font.bold_font)
    window_update(shopName)
  end
  
  #//////////////////////////////////////////////////////////////////////////
  # * Public Methods
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Update
  #--------------------------------------------------------------------------
  def window_update(name)
    if name != nil
      @cShopName.text = name
    end
    refresh()
  end
  
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh()
    self.contents.clear
    @cShopName.draw()
  end
  
end

#==============================================================================
# ** UCShopItem
#------------------------------------------------------------------------------
#  Represents a group of controls for a shoppable item
#==============================================================================

class UCShopItem < UserControl
  
  #//////////////////////////////////////////////////////////////////////////
  # * Attributes
  #//////////////////////////////////////////////////////////////////////////
  
  # Icon control for the shop item
  attr_reader   :ucIcon
  # Label control for the shop item name
  attr_reader   :cItemName
  # Label control for the shop item price
  attr_reader   :cItemPrice
  # Label control for the shop item possession in the inventory
  attr_reader   :cItemPossess
  # Label control for the shop item current selected quantity
  attr_reader   :ucItemNumber
  # Item object
  attr_reader   :item
  
  #//////////////////////////////////////////////////////////////////////////
  # * Properties
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Set the visible property of the controls in the user control
  #--------------------------------------------------------------------------
  # SET
  def visible=(visible)
    @visible = visible
    @ucIcon.visible = visible
    @cItemName.visible = visible
    @cItemPrice.visible = visible
    @cItemPossess.visible = visible
    @ucItemNumber.visible = visible
  end

  #--------------------------------------------------------------------------
  # * Set the active property of the controls in the user control
  #--------------------------------------------------------------------------
  # SET
  def active=(active)
    @active = active
    @ucIcon.active = active
    @cItemName.active = active
    @cItemPrice.active = active
    @cItemPossess.active = active
    @ucItemNumber.active = active
  end
  
  #--------------------------------------------------------------------------
  # * Get the current selected quantity of the item
  #--------------------------------------------------------------------------
  # GET
  def quantity
    return @ucItemNumber.value
  end
  
  #--------------------------------------------------------------------------
  # * Get the current quantity of the item in the inventory
  #--------------------------------------------------------------------------
  # GET
  def inventory_quantity
    return @cItemPossess.text.to_i
  end
  
  #//////////////////////////////////////////////////////////////////////////
  # * Constructors
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Object Initialization
  #     window : window in which the user control will appear
  #     item : item object
  #     rect : rectangle to position the controls for the item
  #     itemNumberPattern : Pattern to use for the UCNumericUpDown control
  #     spacing : spacing between controls
  #     active : control activity
  #     visible : control visibility
  #--------------------------------------------------------------------------
  def initialize(window, item, rect, itemNumberPattern, spacing=8,
                 active=true, visible=true)
    super(active, visible)
    @item = item
    
    # Determine rectangles to position controls
    rects = determine_rects(rect, spacing)
    
    @ucIcon = UCIcon.new(window, rects[0], item.icon_index)
    @ucIcon.active = active
    @ucIcon.visible = visible

    @cItemName = CLabel.new(window, rects[1], item.name)
    @cItemName.active = active
    @cItemName.visible = visible
    @cItemName.cut_overflow = true

    @cItemPrice = CLabel.new(window, rects[2], item.price)
    @cItemPrice.active = active
    @cItemPrice.visible = visible

    @cItemPossess = CLabel.new(window, rects[3], $game_party.item_number(item))
    @cItemPossess.active = active
    @cItemPossess.visible = visible

    @ucItemNumber = UCNumericUpDown.new(window, rects[4], 0, itemNumberPattern)
    @ucItemNumber.active = active
    @ucItemNumber.visible = visible
  end
  
  #//////////////////////////////////////////////////////////////////////////
  # * Public Methods
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Draw the groups of controls on the window
  #--------------------------------------------------------------------------
  def draw()
    @ucIcon.draw()
    @cItemName.draw()
    @cItemPrice.draw()
    @cItemPossess.draw()
    @ucItemNumber.draw()
  end
  
  #--------------------------------------------------------------------------
  # * Returns true if the quantity of items == max of the numeric up down
  #--------------------------------------------------------------------------
  def is_max_number?()
    return @ucItemNumber.value == @ucItemNumber.max
  end
  
  #--------------------------------------------------------------------------
  # * Returns true if the quantity of items == min of the numeric up down
  #--------------------------------------------------------------------------
  def is_min_number?()
    return @ucItemNumber.value == @ucItemNumber.min
  end
  
  #//////////////////////////////////////////////////////////////////////////
  # * Private Methods
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Determine rectangles to positions controls in the user control
  #     rect : base rectangle to position the controls
  #     spacing : spacing between controls
  #--------------------------------------------------------------------------
  def determine_rects(rect, spacing)
    rects = []
    
    # Rects Initialization
    rects[0] = Rect.new(rect.x,rect.y,24,rect.height)
    rects[1] = Rect.new(rect.x,rect.y,rect.width,rect.height)
    rects[2] = Rect.new(rect.x,rect.y,64,rect.height)
    rects[3] = Rect.new(rect.x,rect.y,24,rect.height)
    rects[4] = Rect.new(rect.x,rect.y,32,rect.height)
    
    # Rects Adjustments
    
    # ucIcon
    # Nothing to do
    
    # cItemName
    rects[1].x += rects[0].width
    rects[1].width = rect.width - rects[0].width - rects[2].width - rects[3].width - rects[4].width - (spacing*3)
    
    # cItemPrice
    rects[2].x += rect.width - rects[2].width - rects[3].width - rects[4].width - (spacing*2)
    
    # cItemPossess   
    rects[3].x += rect.width - rects[3].width - rects[4].width - spacing
    
    # ucItemNumber
    rects[4].x += rect.width - rects[4].width
    
    return rects
  end
  private :determine_rects
  
end

#==============================================================================
# ** UCShopStatus
#------------------------------------------------------------------------------
#  Represents a group of controls to show the character status when shopping
#==============================================================================

class UCShopStatus < UserControl
  
  #//////////////////////////////////////////////////////////////////////////
  # * Attributes
  #//////////////////////////////////////////////////////////////////////////
  
  # Control to show the character graphic
  attr_reader :ucCharGraphic
  # UCLabelValue for the ATK stat of the character
  attr_reader :ucAtkStat
  # UCLabelValue for the DEF stat of the character
  attr_reader :ucDefStat
  # UCLabelValue for the SPI stat of the character
  attr_reader :ucSpiStat
  # UCLabelValue for the AGI stat of the character
  attr_reader :ucAgiStat
  # UCLabelValue for the EVA stat of the character
  attr_reader :ucEvaStat
  # UCLabelValue for the HIT stat of the character
  attr_reader :ucHitStat
  # Label for message (equivalent, can't equip and already equipped)
  attr_reader :cMsg
  # Actor object
  attr_reader :actor
  
  #//////////////////////////////////////////////////////////////////////////
  # * Properties
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Set the visible property of the controls in the user control
  #--------------------------------------------------------------------------
  # SET
  def visible=(visible)
    @visible = visible
    @ucCharGraphic.visible = visible
    @ucAtkStat.visible = visible
    @ucDefStat.visible = visible
    @ucSpiStat.visible = visible
    @ucAgiStat.visible = visible
    @ucEvaStat.visible = visible
    @ucHitStat.visible = visible
    @cMsg.visible = visible
  end

  #--------------------------------------------------------------------------
  # * Set the active property of the controls in the user control
  #--------------------------------------------------------------------------
  # SET
  def active=(active)
    @active = active
    @ucCharGraphic.active = active
    @ucAtkStat.active = active
    @ucDefStat.active = active
    @ucSpiStat.active = active
    @ucAgiStat.active = active
    @ucEvaStat.active = active
    @ucHitStat.active = active
    @cMsg.active = active
  end
  
  #//////////////////////////////////////////////////////////////////////////
  # * Constructors
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Object Initialization
  #     window : window in which the user control will appear
  #     actor : actor object
  #     rect : rectangle to position the controls for the actor
  #     active : control activity
  #     visible : control visibility
  #--------------------------------------------------------------------------
  def initialize(window, actor, rect, spacing=16, 
                 active=true, visible=true)
    super(active, visible)
    @actor = actor
    
    # Determine rectangles to position controls
    rects = determine_rects(rect, spacing)
    
    @ucCharGraphic = UCCharacterGraphic.new(window, rects[0], actor, 1, 255, 1)
    @ucCharGraphic.active = active
    @ucCharGraphic.visible = visible

    @ucAtkStat = UCLabelValue.new(window, rects[1][0], rects[1][1], Vocab::atk_label, 0)
    @ucAtkStat.active = active
    @ucAtkStat.visible = visible
    @ucAtkStat.cLabel.font = Font.compare_stats_font
    @ucAtkStat.cValue.font = Font.compare_stats_font
    
    @ucDefStat = UCLabelValue.new(window, rects[2][0], rects[2][1], Vocab::def_label, 0)
    @ucDefStat.active = active
    @ucDefStat.visible = visible
    @ucDefStat.cLabel.font = Font.compare_stats_font
    @ucDefStat.cValue.font = Font.compare_stats_font
    
    @ucSpiStat = UCLabelValue.new(window, rects[3][0], rects[3][1], Vocab::spi_label, 0)
    @ucSpiStat.active = active
    @ucSpiStat.visible = visible
    @ucSpiStat.cLabel.font = Font.compare_stats_font
    @ucSpiStat.cValue.font = Font.compare_stats_font
    
    @ucAgiStat = UCLabelValue.new(window, rects[4][0], rects[4][1], Vocab::agi_label, 0)
    @ucAgiStat.active = active
    @ucAgiStat.visible = visible
    @ucAgiStat.cLabel.font = Font.compare_stats_font
    @ucAgiStat.cValue.font = Font.compare_stats_font
    
    @ucEvaStat = UCLabelValue.new(window, rects[5][0], rects[5][1], Vocab::eva_label, 0)
    @ucEvaStat.active = active
    @ucEvaStat.visible = visible
    @ucEvaStat.cLabel.font = Font.compare_stats_font
    @ucEvaStat.cValue.font = Font.compare_stats_font
    
    @ucHitStat = UCLabelValue.new(window, rects[6][0], rects[6][1], Vocab::hit_label, 0)
    @ucHitStat.active = active
    @ucHitStat.visible = visible
    @ucHitStat.cLabel.font = Font.compare_stats_font
    @ucHitStat.cValue.font = Font.compare_stats_font
    
    @cMsg = CLabel.new(window, rects[7], "")
    @cMsg.active = active
    @cMsg.visible = visible
  end
  
  #//////////////////////////////////////////////////////////////////////////
  # * Public Methods
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Draw the controls
  #--------------------------------------------------------------------------
  def draw()
    @ucCharGraphic.draw()
    @ucAtkStat.draw()
    @ucDefStat.draw()
    @ucSpiStat.draw()
    @ucAgiStat.draw()
    @ucEvaStat.draw()
    @ucHitStat.draw()
    @cMsg.draw()
  end
  
  #//////////////////////////////////////////////////////////////////////////
  # * Private Methods
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Determine rectangles to positions controls in the user control
  #     rect : base rectangle to position the controls
  #     spacing : spacing between controls
  #--------------------------------------------------------------------------
  def determine_rects(rect, spacing)
    rects = []
    
    # Rects Initialization
    rects[0] = Rect.new(rect.x,rect.y,40,rect.height)
    rects[1] = [Rect.new(rect.x,rect.y,35,24),
                Rect.new(rect.x,rect.y,rect.width,24)]
    rects[2] = [Rect.new(rect.x,rect.y,35,24),
                Rect.new(rect.x,rect.y,rect.width,24)]
    rects[3] = [Rect.new(rect.x,rect.y,35,24),
                Rect.new(rect.x,rect.y,rect.width,24)]
    rects[4] = [Rect.new(rect.x,rect.y,35,24),
                Rect.new(rect.x,rect.y,rect.width,24)]
    rects[5] = [Rect.new(rect.x,rect.y,35,24),
                Rect.new(rect.x,rect.y,rect.width,24)]
    rects[6] = [Rect.new(rect.x,rect.y,35,24),
                Rect.new(rect.x,rect.y,rect.width,24)]
    rects[7] = Rect.new(rect.x,rect.y,rect.width,24)
    
    adjust_y = (rect.height / (3*24)).floor
    value_width = ((rect.width - rects[0].width - (35*2) - spacing) / 2).floor
       
    # Rects Adjustments
    
    # ucCharGraphic
    # Nothing to do
    
    # ucAtkStat
    rects[1][0].x += rects[0].width
    rects[1][0].y += adjust_y
    rects[1][1].x = rects[1][0].x + rects[1][0].width
    rects[1][1].y = rects[1][0].y
    rects[1][1].width = value_width

    # ucDefStat
    rects[2][0].x += rects[0].width + rects[1][0].width + value_width + spacing
    rects[2][0].y += adjust_y
    rects[2][1].x = rects[2][0].x + rects[2][0].width
    rects[2][1].y = rects[2][0].y
    rects[2][1].width = value_width
    
    # ucSpiStat   
    rects[3][0].x += rects[0].width
    rects[3][0].y += adjust_y + spacing
    rects[3][1].x = rects[3][0].x + rects[3][0].width
    rects[3][1].y = rects[3][0].y
    rects[3][1].width = value_width
    
    # ucAgiStat
    rects[4][0].x += rects[0].width + rects[3][0].width + value_width + spacing
    rects[4][0].y += adjust_y + spacing
    rects[4][1].x = rects[4][0].x + rects[4][0].width
    rects[4][1].y = rects[4][0].y
    rects[4][1].width = value_width
    
    # ucEvaStat   
    rects[5][0].x += rects[0].width
    rects[5][0].y += adjust_y + (spacing*2)
    rects[5][1].x = rects[5][0].x + rects[5][0].width
    rects[5][1].y = rects[5][0].y
    rects[5][1].width = value_width
    
    # ucHitStat
    rects[6][0].x += rects[0].width + rects[5][0].width + value_width + spacing
    rects[6][0].y += adjust_y + (spacing*2)
    rects[6][1].x = rects[6][0].x + rects[6][0].width
    rects[6][1].y = rects[6][0].y
    rects[6][1].width = value_width
    
    # cMsg
    rects[7].x += rects[0].width
    rects[7].y += ((rect.height-rects[7].height)/2).floor
    
    return rects
  end
  private :determine_rects
  
end

#==============================================================================
# ** ShopStatusCompare
#------------------------------------------------------------------------------
#  Represents the differences between two RPG::Item
#==============================================================================

class ShopStatusCompare
  
  #//////////////////////////////////////////////////////////////////////////
  # * Attributes
  #//////////////////////////////////////////////////////////////////////////
  
  # Item object 1 to compare
  attr_reader :item1
  # Item object 2 to compare
  attr_reader :item2
  # Difference value of the ATK stat
  attr_reader :atkDifference
  # Difference value of the DEF stat
  attr_reader :defDifference
  # Difference value of the SPI stat
  attr_reader :spiDifference
  # Difference value of the AGI stat
  attr_reader :agiDifference
  # Difference value of the EVA stat
  attr_reader :evaDifference
  # Difference value of the HIT stat
  attr_reader :hitDifference
  
  #//////////////////////////////////////////////////////////////////////////
  # * Constructors
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Object Initialization
  #     item1 : Item to compare
  #     item2 : Another item
  #--------------------------------------------------------------------------
  def initialize(item1, item2)
    @item1 = item1
    @item2 = item2
    if item1 != nil && item2 != nil
      calculate(item1, item2)
    elsif item1 == nil && item2 != nil
      calculate(duplicate_empty_item(item2), item2)
    elsif item1 != nil && item2 == nil
      calculate(item1, duplicate_empty_item(item1))
    else
      @atkDifference = 0
      @defDifference = 0
      @spiDifference = 0
      @agiDifference = 0
      @evaDifference = 0
      @hitDifference = 0
    end
    
  end
  
  #//////////////////////////////////////////////////////////////////////////
  # * Public Methods
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Returns true if item1 and item2 are equivalent
  #--------------------------------------------------------------------------
  def is_equivalent()
    return !is_same() && 
           @atkDifference == 0 && 
           @defDifference == 0 &&
           @spiDifference == 0 &&
           @agiDifference == 0 &&
           @evaDifference == 0 &&
           @hitDifference == 0
  end
  
  #--------------------------------------------------------------------------
  # * Returns true if item1 and item2 are the same
  #--------------------------------------------------------------------------
  def is_same()
    return @item1.id == @item2.id
  end
  
  #//////////////////////////////////////////////////////////////////////////
  # * Private Methods
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Calculate the difference between the two items
  #     item1 : Item to compare
  #     item2 : Another item
  #--------------------------------------------------------------------------
  def calculate(item1, item2)
    @atkDifference = item1.atk - item2.atk
    @defDifference = item1.def - item2.def
    @spiDifference = item1.spi - item2.spi
    @agiDifference = item1.agi - item2.agi
    if item1.is_a?(RPG::Armor) && item2.is_a?(RPG::Armor)
      @evaDifference = item1.eva - item2.eva
    elsif !item1.is_a?(RPG::Armor) && item2.is_a?(RPG::Armor)
      @evaDifference = 0 - item2.eva
    elsif item1.is_a?(RPG::Armor) && !item2.is_a?(RPG::Armor)
      @evaDifference = item1.eva - 0
    else
      @evaDifference = 0
    end
    if item1.is_a?(RPG::Weapon) && item2.is_a?(RPG::Weapon)
      @hitDifference = item1.hit - item2.hit
    elsif !item1.is_a?(RPG::Weapon) && item2.is_a?(RPG::Weapon)
      @hitDifference = 0 - item2.hit
    elsif item1.is_a?(RPG::Weapon) && !item2.is_a?(RPG::Weapon)
      @hitDifference = item1.hit - 0
    else
      @hitDifference = 0
    end
  end
  private :calculate
  
  #--------------------------------------------------------------------------
  # * Create an empty comparable item depending of the type of 
  #   the other item to compare
  #     item : Item to compare
  #--------------------------------------------------------------------------
  def duplicate_empty_item(item)
    if item.is_a?(RPG::Weapon)
      return RPG::Weapon.new()
    elsif item.is_a?(RPG::Armor)
      return RPG::Armor.new()
    else
      return nil
    end
  end
  private :duplicate_empty_item
  
end

