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
