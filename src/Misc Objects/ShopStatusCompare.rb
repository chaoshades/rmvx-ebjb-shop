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
