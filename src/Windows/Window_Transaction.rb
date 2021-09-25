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
