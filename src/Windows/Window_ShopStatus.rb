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
