module EBJB_Shop
  # Build filename
  FINAL   = "build/EBJB_Shop.rb"
  # Source files
  TARGETS = [
	"src/Script_Header.rb",
    "src/Shop_Config.rb",
    "src/Game Objects/Game_Temp.rb",
    "src/Scenes/Scene_Shop.rb",
    "src/Scenes/Scene_Equip.rb",
    "src/User Interface/Font.rb",
    "src/User Interface/Color.rb",
    "src/User Interface/Vocab.rb",
    "src/Windows/Window_ShopGold.rb",
    "src/Windows/Window_Transaction.rb",
    "src/Windows/Window_Shop.rb",
    "src/Windows/Window_ShopBuy.rb",
    "src/Windows/Window_ShopSell.rb",
    "src/Windows/Window_ShopStatus.rb",
    "src/Windows/Window_ShopName.rb",
    "src/User Controls/UCShopItem.rb",
    "src/User Controls/UCShopStatus.rb",
    "src/Misc Objects/ShopStatusCompare.rb",
  ]
end

def ebjb_build
  final = File.new(EBJB_Shop::FINAL, "w+")
  EBJB_Shop::TARGETS.each { |file|
    src = File.open(file, "r+")
    final.write(src.read + "\n")
    src.close
  }
  final.close
end

ebjb_build()
