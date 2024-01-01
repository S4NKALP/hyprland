#!/bin/bash

# Rofi Emoticons. Not my own. Cant remember the source

sed '1,/^### DATA ###$/d' $0 |
rofi -dmenu -config ~/.config/rofi/config-emoji.rasi |
cut -d ' ' -f 1 | tr -d '\n' | wl-copy

exit

### DATA ###
😀 Grinning Face
😁 Beaming Face With Smiling Eyes
😂 Face With Tears Of Joy
🤣 Rolling On The Floor Laughing
😃 Grinning Face With Big Eyes
😄 Grinning Face With Smiling Eyes
😅 Grinning Face With Sweat
😆 Grinning Squinting Face
😉 Winking Face
😊 Smiling Face With Smiling Eyes
🥰 Smiling Face with Hearts
😋 Face Savoring Food
😎 Smiling Face With Sunglasses
😍 Smiling Face With Heart-Eyes
😘 Face Blowing A Kiss
😗 Kissing Face
😙 Kissing Face With Smiling Eyes
😚 Kissing Face With Closed Eyes
☺️ Smiling Face
🙂 Slightly Smiling Face
🤗 Hugging Face
🤩 Star-Struck
🤔 Thinking Face
🤨 Face With Raised Eyebrow
😐 Neutral Face
😑 Expressionless Face
😶 Face Without Mouth
🙄 Face With Rolling Eyes
😏 Smirking Face
😣 Persevering Face
😥 Sad But Relieved Face
😮 Face With Open Mouth
🤐 Zipper-Mouth Face
😯 Hushed Face
😪 Sleepy Face
😫 Tired Face
🥱 Yawning Face
😴 Sleeping Face
😌 Relieved Face
😛 Face With Tongue
😜 Winking Face With Tongue
😝 Squinting Face With Tongue
🤤 Drooling Face
😒 Unamused Face
😓 Downcast Face With Sweat
😔 Pensive Face
😕 Confused Face
🙃 Upside-Down Face
🤑 Money-Mouth Face
😲 Astonished Face
☹️ Frowning Face
🙁 Slightly Frowning Face
😖 Confounded Face
😞 Disappointed Face
😟 Worried Face
😤 Face With Steam From Nose
😢 Crying Face
😭 Loudly Crying Face
😦 Frowning Face With Open Mouth
😧 Anguished Face
😨 Fearful Face
😩 Weary Face
🤯 Exploding Head
😬 Grimacing Face
😰 Anxious Face With Sweat
😱 Face Screaming In Fear
😳 Flushed Face
🥺 pleading face
🤪 Zany Face
😵 Dizzy Face
😡 Pouting Face
😠 Angry Face
🤬 Face With Symbols On Mouth
😷 Face With Medical Mask
🤒 Face With Thermometer
🤕 Face With Head-Bandage
🤢 Nauseated Face
🤮 Face Vomiting
🤧 Sneezing Face
😇 Smiling Face With Halo
🤠 Cowboy Hat Face
🤥 Lying Face
🤫 Shushing Face
🤭 Face With Hand Over Mouth
🧐 Face With Monocle
🤓 Nerd Face
😈 Smiling Face With Horns
👿 Angry Face With Horns
🤡 Clown Face
👹 Ogre
👺 Goblin
💀 Skull
☠️ Skull And Crossbones
👻 Ghost
👽 Alien
👾 Alien Monster
🤖 Robot Face
💩 Pile Of Poo
😺 Grinning Cat Face
😸 Grinning Cat Face With Smiling Eyes
😹 Cat Face With Tears Of Joy
😻 Smiling Cat Face With Heart-Eyes
😼 Cat Face With Wry Smile
😽 Kissing Cat Face
🙀 Weary Cat Face
😿 Crying Cat Face
😾 Pouting Cat Face
🙈 See-No-Evil Monkey
🙉 Hear-No-Evil Monkey
🙊 Speak-No-Evil Monkey
👶 Baby
🧒 Child
👦 Boy
👧 Girl
🧑 Adult
👨 Man
👩 Woman
🧓 Older Adult
👴 Old Man
👵 Old Woman
👨‍⚕️ Man Health Worker
👩‍⚕️ Woman Health Worker
👨‍🎓 Man Student
👩‍🎓 Woman Student
👨‍🏫 Man Teacher
👩‍🏫 Woman Teacher
👨‍⚖️ Man Judge
👩‍⚖️ Woman Judge
👨‍🌾 Man Farmer
👩‍🌾 Woman Farmer
👨‍🍳 Man Cook
👩‍🍳 Woman Cook
👨‍🔧 Man Mechanic
👩‍🔧 Woman Mechanic
👨‍🏭 Man Factory Worker
👩‍🏭 Woman Factory Worker
👨‍💼 Man Office Worker
👩‍💼 Woman Office Worker
👨‍🔬 Man Scientist
👩‍🔬 Woman Scientist
👨‍💻 Man Technologist
👩‍💻 Woman Technologist
👨‍🎤 Man Singer
👩‍🎤 Woman Singer
👨‍🎨 Man Artist
👩‍🎨 Woman Artist
👨‍✈️ Man Pilot
👩‍✈️ Woman Pilot
👨‍🚀 Man Astronaut
👩‍🚀 Woman Astronaut
👨‍🚒 Man Firefighter
👩‍🚒 Woman Firefighter
👮 Police Officer
👮‍♂️ Man Police Officer
👮‍♀️ Woman Police Officer
🕵️ Detective
🕵️‍♂️ Man Detective
🕵️‍♀️ Woman Detective
💂 Guard
💂‍♂️ Man Guard
💂‍♀️ Woman Guard
👷 Construction Worker
👷‍♂️ Man Construction Worker
👷‍♀️ Woman Construction Worker
🤴 Prince
👸 Princess
👳 Person Wearing Turban
👳‍♂️ Man Wearing Turban
👳‍♀️ Woman Wearing Turban
👲 Man With Chinese Cap
🧕 Woman With Headscarf
🧔 Bearded Person
👱‍♂️ Blond-Haired Man
👱‍♀️ Blond-Haired Woman
🤵 Man In Tuxedo
👰 Bride With Veil
🤰 Pregnant Woman
🤱 Breast-Feeding
👼 Baby Angel
🎅 Santa Claus
🤶 Mrs. Claus
🧙 Mage
🧙‍♀️ Woman Mage
🧙‍♂️ Man Mage
🧚 Fairy
🧚‍♀️ Woman Fairy
🧚‍♂️ Man Fairy
🧛 Vampire
🧛‍♀️ Woman Vampire
🧛‍♂️ Man Vampire
🧜 Merperson
🧜‍♀️ Mermaid
🧜‍♂️ Merman
🧝 Elf
🧝‍♀️ Woman Elf
🧝‍♂️ Man Elf
🧞 Genie
🧞‍♀️ Woman Genie
🧞‍♂️ Man Genie
🧟 Zombie
🧟‍♀️ Woman Zombie
🧟‍♂️ Man Zombie
🙍 Person Frowning
🙍‍♂️ Man Frowning
🙍‍♀️ Woman Frowning
🙎 Person Pouting
🙎‍♂️ Man Pouting
🙎‍♀️ Woman Pouting
🙅 Person Gesturing No
🙅‍♂️ Man Gesturing No
🙅‍♀️ Woman Gesturing No
🙆 Person Gesturing Ok
🙆‍♂️ Man Gesturing Ok
🙆‍♀️ Woman Gesturing Ok
💁 Person Tipping Hand
💁‍♂️ Man Tipping Hand
💁‍♀️ Woman Tipping Hand
🙋 Person Raising Hand
🙋‍♂️ Man Raising Hand
🙋‍♀️ Woman Raising Hand
🙇 Person Bowing
🙇‍♂️ Man Bowing
🙇‍♀️ Woman Bowing
🤦 Person Facepalming
🤦‍♂️ Man Facepalming
🤦‍♀️ Woman Facepalming
🤷 Person Shrugging
🤷‍♂️ Man Shrugging
🤷‍♀️ Woman Shrugging
💆 Person Getting Massage
💆‍♂️ Man Getting Massage
💆‍♀️ Woman Getting Massage
💇 Person Getting Haircut
💇‍♂️ Man Getting Haircut
💇‍♀️ Woman Getting Haircut
🚶 Person Walking
🚶‍♂️ Man Walking
🚶‍♀️ Woman Walking
🏃 Person Running
🏃‍♂️ Man Running
🏃‍♀️ Woman Running
💃 Woman Dancing
🕺 Man Dancing
👯 People With Bunny Ears
👯‍♂️ Men With Bunny Ears
👯‍♀️ Women With Bunny Ears
🧖 Person In Steamy Room
🧖‍♀️ Woman In Steamy Room
🧖‍♂️ Man In Steamy Room
🧗 Person Climbing
🧗‍♀️ Woman Climbing
🧗‍♂️ Man Climbing
🧘 Person In Lotus Position
🧘‍♀️ Woman In Lotus Position
🧘‍♂️ Man In Lotus Position
🛀 Person Taking Bath
🛌 Person In Bed
🕴️ Man In Suit Levitating
🗣️ Speaking Head
👤 Bust In Silhouette
👥 Busts In Silhouette
🤺 Person Fencing
🏇 Horse Racing
⛷️ Skier
🏂 Snowboarder
🏌️ Person Golfing
🏌️‍♂️ Man Golfing
🏌️‍♀️ Woman Golfing
🏄 Person Surfing
🏄‍♂️ Man Surfing
🏄‍♀️ Woman Surfing
🚣 Person Rowing Boat
🚣‍♂️ Man Rowing Boat
🚣‍♀️ Woman Rowing Boat
🏊 Person Swimming
🏊‍♂️ Man Swimming
🏊‍♀️ Woman Swimming
⛹️ Person Bouncing Ball
⛹️‍♂️ Man Bouncing Ball
⛹️‍♀️ Woman Bouncing Ball
🏋️ Person Lifting Weights
🏋️‍♂️ Man Lifting Weights
🏋️‍♀️ Woman Lifting Weights
🚴 Person Biking
🚴‍♂️ Man Biking
🚴‍♀️ Woman Biking
🚵 Person Mountain Biking
🚵‍♂️ Man Mountain Biking
🚵‍♀️ Woman Mountain Biking
🏎️ Racing Car
🏍️ Motorcycle
🤸 Person Cartwheeling
🤸‍♂️ Man Cartwheeling
🤸‍♀️ Woman Cartwheeling
🤼 People Wrestling
🤼‍♂️ Men Wrestling
🤼‍♀️ Women Wrestling
🤽 Person Playing Water Polo
🤽‍♂️ Man Playing Water Polo
🤽‍♀️ Woman Playing Water Polo
🤾 Person Playing Handball
🤾‍♂️ Man Playing Handball
🤾‍♀️ Woman Playing Handball
🤹 Person Juggling
🤹‍♂️ Man Juggling
🤹‍♀️ Woman Juggling
👫 Man And Woman Holding Hands
👬 Two Men Holding Hands
👭 Two Women Holding Hands
💏 Kiss
💑 Couple With Heart
👪 Family
🤳 Selfie
💪 Flexed Biceps
👈 Backhand Index Pointing Left
👉 Backhand Index Pointing Right
☝️ Index Pointing Up
👆 Backhand Index Pointing Up
🖕 Middle Finger
👇 Backhand Index Pointing Down
✌️ Victory Hand
🤞 Crossed Fingers
🖖 Vulcan Salute
🤘 Sign Of The Horns
🤙 Call Me Hand
🖐️ Hand With Fingers Splayed
✋ Raised Hand
👌 Ok Hand
👍 Thumbs Up
👎 Thumbs Down
✊ Raised Fist
👊 Oncoming Fist
🤛 Left-Facing Fist
🤜 Right-Facing Fist
🤚 Raised Back Of Hand
👋 Waving Hand
🤟 Love-You Gesture
✍️ Writing Hand
👏 Clapping Hands
👐 Open Hands
🙌 Raising Hands
🤲 Palms Up Together
🙏 Folded Hands
🤝 Handshake
💅 Nail Polish
👂 Ear
👃 Nose
👣 Footprints
👀 Eyes
👁️ Eye
👁️‍🗨️ Eye In Speech Bubble
🧠 Brain
👅 Tongue
👄 Mouth
💋 Kiss Mark
💘 Heart With Arrow
❤️ Red Heart
💓 Beating Heart
💔 Broken Heart
💕 Two Hearts
💖 Sparkling Heart
💗 Growing Heart
💙 Blue Heart
💚 Green Heart
💛 Yellow Heart
🧡 Orange Heart
💜 Purple Heart
🖤 Black Heart
🤍 White Heart
🤎 Brown Heart
💝 Heart With Ribbon
💞 Revolving Hearts
💟 Heart Decoration
❣️ Heavy Heart Exclamation
💌 Love Letter
💤 Zzz
💢 Anger Symbol
💣 Bomb
💥 Collision
💦 Sweat Droplets
💨 Dashing Away
💫 Dizzy
💬 Speech Balloon
🗨️ Left Speech Bubble
🗯️ Right Anger Bubble
💭 Thought Balloon
🕳️ Hole
👓 Glasses
🕶️ Sunglasses
👔 Necktie
👕 T-Shirt
👖 Jeans
🧣 Scarf
🧤 Gloves
🧥 Coat
🧦 Socks
👗 Dress
👘 Kimono
👙 Bikini
👚 Woman's Clothes
👛 Purse
👜 Handbag
👝 Clutch Bag
🛍️ Shopping Bags
🎒 School Backpack
👞 Man's Shoe
👟 Running Shoe
👠 High-Heeled Shoe
👡 Woman's Sandal
👢 Woman's Boot
👑 Crown
👒 Woman's Hat
🎩 Top Hat
🎓 Graduation Cap
🧢 Billed Cap
⛑️ Rescue Worker's Helmet
📿 Prayer Beads
💄 Lipstick
💍 Ring
💎 Gem Stone
🐵 Monkey Face
🐒 Monkey
🦍 Gorilla
🐶 Dog Face
🐕 Dog
🐩 Poodle
🐺 Wolf Face
🦊 Fox Face
🐱 Cat Face
🐈 Cat
🦁 Lion Face
🐯 Tiger Face
🐅 Tiger
🐆 Leopard
🐴 Horse Face
🐎 Horse
🦄 Unicorn Face
🦓 Zebra
🦌 Deer
🐮 Cow Face
🐂 Ox
🐃 Water Buffalo
🐄 Cow
🐷 Pig Face
🐖 Pig
🐗 Boar
🐽 Pig Nose
🐏 Ram
🐑 Ewe
🐐 Goat
🐪 Camel
🐫 Two-Hump Camel
🦒 Giraffe
🐘 Elephant
🦏 Rhinoceros
🐭 Mouse Face
🐁 Mouse
🐀 Rat
🐹 Hamster Face
🐰 Rabbit Face
🐇 Rabbit
🐿️ Chipmunk
🦔 Hedgehog
🦇 Bat
🐻 Bear Face
🐨 Koala
🐼 Panda Face
🐾 Paw Prints
🦃 Turkey
🐔 Chicken
🐓 Rooster
🐣 Hatching Chick
🐤 Baby Chick
🐥 Front-Facing Baby Chick
🐦 Bird
🐧 Penguin
🕊️ Dove
🦅 Eagle
🦆 Duck
🦉 Owl
🐸 Frog Face
🐊 Crocodile
🐢 Turtle
🦎 Lizard
🐍 Snake
🐲 Dragon Face
🐉 Dragon
🦕 Sauropod
🦖 T-Rex
🐳 Spouting Whale
🐋 Whale
🐬 Dolphin
🐟 Fish
🐠 Tropical Fish
🐡 Blowfish
🦈 Shark
🐙 Octopus
🐚 Spiral Shell
🦀 Crab
🦐 Shrimp
🦑 Squid
🐌 Snail
🦋 Butterfly
🐛 Bug
🐜 Ant
🐝 Honeybee
🐞 Lady Beetle
🦗 Cricket
🕷️ Spider
🕸️ Spider Web
🦂 Scorpion
💐 Bouquet
🌸 Cherry Blossom
💮 White Flower
🏵️ Rosette
🌹 Rose
🥀 Wilted Flower
🌺 Hibiscus
🌻 Sunflower
🌼 Blossom
🌷 Tulip
🌱 Seedling
🌲 Evergreen Tree
🌳 Deciduous Tree
🌴 Palm Tree
🌵 Cactus
🌾 Sheaf Of Rice
🌿 Herb
☘️ Shamrock
🍀 Four Leaf Clover
🍁 Maple Leaf
🍂 Fallen Leaf
🍃 Leaf Fluttering In Wind
🍇 Grapes
🍈 Melon
🍉 Watermelon
🍊 Tangerine
🍋 Lemon
🍌 Banana
🍍 Pineapple
🍎 Red Apple
🍏 Green Apple
🍐 Pear
🍑 Peach
🍒 Cherries
🍓 Strawberry
🥝 Kiwi Fruit
🍅 Tomato
🥥 Coconut
🥑 Avocado
🍆 Eggplant
🥔 Potato
🥕 Carrot
🌽 Ear Of Corn
🌶️ Hot Pepper
🥒 Cucumber
🥦 Broccoli
🍄 Mushroom
🥜 Peanuts
🌰 Chestnut
🍞 Bread
🥐 Croissant
🥖 Baguette Bread
🥨 Pretzel
🥞 Pancakes
🧀 Cheese Wedge
🍖 Meat On Bone
🍗 Poultry Leg
🥩 Cut Of Meat
🥓 Bacon
🍔 Hamburger
🍟 French Fries
🍕 Pizza
🌭 Hot Dog
🥪 Sandwich
🌮 Taco
🌯 Burrito
🥙 Stuffed Flatbread
🥚 Egg
🍳 Cooking
🥘 Shallow Pan Of Food
🍲 Pot Of Food
🥣 Bowl With Spoon
🥗 Green Salad
🍿 Popcorn
🥫 Canned Food
🍱 Bento Box
🍘 Rice Cracker
🍙 Rice Ball
🍚 Cooked Rice
🍛 Curry Rice
🍜 Steaming Bowl
🍝 Spaghetti
🍠 Roasted Sweet Potato
🍢 Oden
🍣 Sushi
🍤 Fried Shrimp
🍥 Fish Cake With Swirl
🍡 Dango
🥟 Dumpling
🥠 Fortune Cookie
🥡 Takeout Box
🍦 Soft Ice Cream
🍧 Shaved Ice
🍨 Ice Cream
🍩 Doughnut
🍪 Cookie
🎂 Birthday Cake
🍰 Shortcake
🥧 Pie
🍫 Chocolate Bar
🍬 Candy
🍭 Lollipop
🍮 Custard
🍯 Honey Pot
🍼 Baby Bottle
🥛 Glass Of Milk
☕ Hot Beverage
🍵 Teacup Without Handle
🍶 Sake
🍾 Bottle With Popping Cork
🍷 Wine Glass
🍸 Cocktail Glass
🍹 Tropical Drink
🍺 Beer Mug
🍻 Clinking Beer Mugs
🥂 Clinking Glasses
🥃 Tumbler Glass
🥤 Cup With Straw
🥢 Chopsticks
🍽️ Fork And Knife With Plate
🍴 Fork And Knife
🥄 Spoon
🔪 Kitchen Knife
🏺 Amphora
🌍 Globe Showing Europe-Africa
🌎 Globe Showing Americas
🌏 Globe Showing Asia-Australia
🌐 Globe With Meridians
🗺️ World Map
🗾 Map Of Japan
🏔️ Snow-Capped Mountain
⛰️ Mountain
🌋 Volcano
🗻 Mount Fuji
🏕️ Camping
🏖️ Beach With Umbrella
🏜️ Desert
🏝️ Desert Island
🏞️ National Park
🏟️ Stadium
🏛️ Classical Building
🏗️ Building Construction
🏘️ Houses
🏚️ Derelict House
🏠 House
🏡 House With Garden
🏢 Office Building
🏣 Japanese Post Office
🏤 Post Office
🏥 Hospital
🏦 Bank
🏨 Hotel
🏩 Love Hotel
🏪 Convenience Store
🏫 School
🏬 Department Store
🏭 Factory
🏯 Japanese Castle
🏰 Castle
💒 Wedding
🗼 Tokyo Tower
🗽 Statue Of Liberty
⛪ Church
🕌 Mosque
🕍 Synagogue
⛩️ Shinto Shrine
🕋 Kaaba
⛲ Fountain
⛺ Tent
🌁 Foggy
🌃 Night With Stars
🏙️ Cityscape
🌄 Sunrise Over Mountains
🌅 Sunrise
🌆 Cityscape At Dusk
🌇 Sunset
🌉 Bridge At Night
♨️ Hot Springs
🌌 Milky Way
🎠 Carousel Horse
🎡 Ferris Wheel
🎢 Roller Coaster
💈 Barber Pole
🎪 Circus Tent
🚂 Locomotive
🚃 Railway Car
🚄 High-Speed Train
🚅 Bullet Train
🚆 Train
🚇 Metro
🚈 Light Rail
🚉 Station
🚊 Tram
🚝 Monorail
🚞 Mountain Railway
🚋 Tram Car
🚌 Bus
🚍 Oncoming Bus
🚎 Trolleybus
🚐 Minibus
🚑 Ambulance
🚒 Fire Engine
🚓 Police Car
🚔 Oncoming Police Car
🚕 Taxi
🚖 Oncoming Taxi
🚗 Automobile
🚘 Oncoming Automobile
🚙 Sport Utility Vehicle
🚚 Delivery Truck
🚛 Articulated Lorry
🚜 Tractor
🚲 Bicycle
🛴 Kick Scooter
🛵 Motor Scooter
🚏 Bus Stop
🛣️ Motorway
🛤️ Railway Track
🛢️ Oil Drum
⛽ Fuel Pump
🚨 Police Car Light
🚥 Horizontal Traffic Light
🚦 Vertical Traffic Light
🛑 Stop Sign
🚧 Construction
⚓ Anchor
⛵ Sailboat
🛶 Canoe
🚤 Speedboat
🛳️ Passenger Ship
⛴️ Ferry
🛥️ Motor Boat
🚢 Ship
✈️ Airplane
🛩️ Small Airplane
🛫 Airplane Departure
🛬 Airplane Arrival
💺 Seat
🚁 Helicopter
🚟 Suspension Railway
🚠 Mountain Cableway
🚡 Aerial Tramway
🛰️ Satellite
🚀 Rocket
🛸 Flying Saucer
🛎️ Bellhop Bell
⌛ Hourglass Done
⏳ Hourglass Not Done
⌚ Watch
⏰ Alarm Clock
⏱️ Stopwatch
⏲️ Timer Clock
🕰️ Mantelpiece Clock
🕛 Twelve O’Clock
🕧 Twelve-Thirty
🕐 One O’Clock
🕜 One-Thirty
🕑 Two O’Clock
🕝 Two-Thirty
🕒 Three O’Clock
🕞 Three-Thirty
🕓 Four O’Clock
🕟 Four-Thirty
🕔 Five O’Clock
🕠 Five-Thirty
🕕 Six O’Clock
🕡 Six-Thirty
🕖 Seven O’Clock
🕢 Seven-Thirty
🕗 Eight O’Clock
🕣 Eight-Thirty
🕘 Nine O’Clock
🕤 Nine-Thirty
🕙 Ten O’Clock
🕥 Ten-Thirty
🕚 Eleven O’Clock
🕦 Eleven-Thirty
🌑 New Moon
🌒 Waxing Crescent Moon
🌓 First Quarter Moon
🌔 Waxing Gibbous Moon
🌕 Full Moon
🌖 Waning Gibbous Moon
🌗 Last Quarter Moon
🌘 Waning Crescent Moon
🌙 Crescent Moon
🌚 New Moon Face
🌛 First Quarter Moon Face
🌜 Last Quarter Moon Face
🌡️ Thermometer
☀️ Sun
🌝 Full Moon Face
🌞 Sun With Face
⭐ Star
🌟 Glowing Star
🌠 Shooting Star
☁️ Cloud
⛅ Sun Behind Cloud
⛈️ Cloud With Lightning And Rain
🌤️ Sun Behind Small Cloud
🌥️ Sun Behind Large Cloud
🌦️ Sun Behind Rain Cloud
🌧️ Cloud With Rain
🌨️ Cloud With Snow
🌩️ Cloud With Lightning
🌪️ Tornado
🌫️ Fog
🌬️ Wind Face
🌀 Cyclone
🌈 Rainbow
🌂 Closed Umbrella
☂️ Umbrella
☔ Umbrella With Rain Drops
⛱️ Umbrella On Ground
⚡ High Voltage
❄️ Snowflake
☃️ Snowman
⛄ Snowman Without Snow
☄️ Comet
🔥 Fire
💧 Droplet
🌊 Water Wave
🎃 Jack-O-Lantern
🎄 Christmas Tree
🎆 Fireworks
🎇 Sparkler
✨ Sparkles
🎈 Balloon
🎉 Party Popper
🎊 Confetti Ball
🎋 Tanabata Tree
🎍 Pine Decoration
🎎 Japanese Dolls
🎏 Carp Streamer
🎐 Wind Chime
🎑 Moon Viewing Ceremony
🎀 Ribbon
🎁 Wrapped Gift
🎗️ Reminder Ribbon
🎟️ Admission Tickets
🎫 Ticket
🎖️ Military Medal
🏆 Trophy
🏅 Sports Medal
🥇 1St Place Medal
🥈 2Nd Place Medal
🥉 3Rd Place Medal
⚽ Soccer Ball
⚾ Baseball
🏀 Basketball
🏐 Volleyball
🏈 American Football
🏉 Rugby Football
🎾 Tennis
🎳 Bowling
🏏 Cricket Game
🏑 Field Hockey
🏒 Ice Hockey
🏓 Ping Pong
🏸 Badminton
🥊 Boxing Glove
🥋 Martial Arts Uniform
🥅 Goal Net
⛳ Flag In Hole
⛸️ Ice Skate
🎣 Fishing Pole
🎽 Running Shirt
🎿 Skis
🛷 Sled
🥌 Curling Stone
🎯 Direct Hit
🎱 Pool 8 Ball
🔮 Crystal Ball
🎮 Video Game
🕹️ Joystick
🎰 Slot Machine
🎲 Game Die
♠️ Spade Suit
♥️ Heart Suit
♦️ Diamond Suit
♣️ Club Suit
♟️ Chess Pawn
🃏 Joker
🀄 Mahjong Red Dragon
🎴 Flower Playing Cards
🎭 Performing Arts
🖼️ Framed Picture
🎨 Artist Palette
🔇 Muted Speaker
🔈 Speaker Low Volume
🔉 Speaker Medium Volume
🔊 Speaker High Volume
📢 Loudspeaker
📣 Megaphone
📯 Postal Horn
🔔 Bell
🔕 Bell With Slash
🎼 Musical Score
🎵 Musical Note
🎶 Musical Notes
🎙️ Studio Microphone
🎚️ Level Slider
🎛️ Control Knobs
🎤 Microphone
🎧 Headphone
📻 Radio
🎷 Saxophone
🎸 Guitar
🎹 Musical Keyboard
🎺 Trumpet
🎻 Violin
🥁 Drum
📱 Mobile Phone
📲 Mobile Phone With Arrow
☎️ Telephone
📞 Telephone Receiver
📟 Pager
📠 Fax Machine
🔋 Battery
🔌 Electric Plug
💻 Laptop Computer
🖥️ Desktop Computer
🖨️ Printer
⌨️ Keyboard
🖱️ Computer Mouse
🖲️ Trackball
💽 Computer Disk
💾 Floppy Disk
💿 Optical Disk
📀 Dvd
🎥 Movie Camera
🎞️ Film Frames
📽️ Film Projector
🎬 Clapper Board
📺 Television
📷 Camera
📸 Camera With Flash
📹 Video Camera
📼 Videocassette
🔍 Magnifying Glass Tilted Left
🔎 Magnifying Glass Tilted Right
🕯️ Candle
💡 Light Bulb
🔦 Flashlight
🏮 Red Paper Lantern
📔 Notebook With Decorative Cover
📕 Closed Book
📖 Open Book
📗 Green Book
📘 Blue Book
📙 Orange Book
📚 Books
📓 Notebook
📒 Ledger
📃 Page With Curl
📜 Scroll
📄 Page Facing Up
📰 Newspaper
🗞️ Rolled-Up Newspaper
📑 Bookmark Tabs
🔖 Bookmark
🏷️ Label
💰 Money Bag
💴 Yen Banknote
💵 Dollar Banknote
💶 Euro Banknote
💷 Pound Banknote
💸 Money With Wings
💳 Credit Card
💹 Chart Increasing With Yen
💱 Currency Exchange
💲 Heavy Dollar Sign
✉️ Envelope
📧 E-Mail
📨 Incoming Envelope
📩 Envelope With Arrow
📤 Outbox Tray
📥 Inbox Tray
📦 Package
📫 Closed Mailbox With Raised Flag
📪 Closed Mailbox With Lowered Flag
📬 Open Mailbox With Raised Flag
📭 Open Mailbox With Lowered Flag
📮 Postbox
🗳️ Ballot Box With Ballot
✏️ Pencil
✒️ Black Nib
🖋️ Fountain Pen
🖊️ Pen
🖌️ Paintbrush
🖍️ Crayon
📝 Memo
💼 Briefcase
📁 File Folder
📂 Open File Folder
🗂️ Card Index Dividers
📅 Calendar
📆 Tear-Off Calendar
🗒️ Spiral Notepad
🗓️ Spiral Calendar
📇 Card Index
📈 Chart Increasing
📉 Chart Decreasing
📊 Bar Chart
📋 Clipboard
📌 Pushpin
📍 Round Pushpin
📎 Paperclip
🖇️ Linked Paperclips
📏 Straight Ruler
📐 Triangular Ruler
✂️ Scissors
🗃️ Card File Box
🗄️ File Cabinet
🗑️ Wastebasket
🔒 Locked
🔓 Unlocked
🔏 Locked With Pen
🔐 Locked With Key
🔑 Key
🗝️ Old Key
🔨 Hammer
⛏️ Pick
⚒️ Hammer And Pick
🛠️ Hammer And Wrench
🗡️ Dagger
⚔️ Crossed Swords
🔫 Pistol
🏹 Bow And Arrow
🛡️ Shield
🔧 Wrench
🔩 Nut And Bolt
⚙️ Gear
🗜️ Clamp
⚖️ Balance Scale
🔗 Link
⛓️ Chains
⚗️ Alembic
🔬 Microscope
🔭 Telescope
📡 Satellite Antenna
💉 Syringe
💊 Pill
🚪 Door
🛏️ Bed
🛋️ Couch And Lamp
🚽 Toilet
🚿 Shower
🛁 Bathtub
🛒 Shopping Cart
🚬 Cigarette
⚰️ Coffin
⚱️ Funeral Urn
🗿 Moai
🏧 Atm Sign
🚮 Litter In Bin Sign
🚰 Potable Water
♿ Wheelchair Symbol
🚹 Men's Room
🚺 Women's Room
🚻 Restroom
🚼 Baby Symbol
🚾 Water Closet
🛂 Passport Control
🛃 Customs
🛄 Baggage Claim
🛅 Left Luggage
⚠️ Warning
🚸 Children Crossing
⛔ No Entry
🚫 Prohibited
🚳 No Bicycles
🚭 No Smoking
🚯 No Littering
🚱 Non-Potable Water
🚷 No Pedestrians
📵 No Mobile Phones
🔞 No One Under Eighteen
☢️ Radioactive
☣️ Biohazard
⬆️ Up Arrow
↗️ Up-Right Arrow
➡️ Right Arrow
↘️ Down-Right Arrow
⬇️ Down Arrow
↙️ Down-Left Arrow
⬅️ Left Arrow
↖️ Up-Left Arrow
↕️ Up-Down Arrow
↔️ Left-Right Arrow
↩️ Right Arrow Curving Left
↪️ Left Arrow Curving Right
⤴️ Right Arrow Curving Up
⤵️ Right Arrow Curving Down
🔃 Clockwise Vertical Arrows
🔄 Counterclockwise Arrows Button
🔙 Back Arrow
🔚 End Arrow
🔛 On! Arrow
🔜 Soon Arrow
🔝 Top Arrow
🛐 Place Of Worship
⚛️ Atom Symbol
🕉️ Om
✡️ Star Of David
☸️ Wheel Of Dharma
☯️ Yin Yang
✝️ Latin Cross
☦️ Orthodox Cross
☪️ Star And Crescent
☮️ Peace Symbol
🕎 Menorah
🔯 Dotted Six-Pointed Star
♈ Aries
♉ Taurus
♊ Gemini
♋ Cancer
♌ Leo
♍ Virgo
♎ Libra
♏ Scorpio
♐ Sagittarius
♑ Capricorn
♒ Aquarius
♓ Pisces
⛎ Ophiuchus
🔀 Shuffle Tracks Button
🔁 Repeat Button
🔂 Repeat Single Button
▶️ Play Button
⏩ Fast-Forward Button
⏭️ Next Track Button
⏯️ Play Or Pause Button
◀️ Reverse Button
⏪ Fast Reverse Button
⏮️ Last Track Button
🔼 Upwards Button
⏫ Fast Up Button
🔽 Downwards Button
⏬ Fast Down Button
⏸️ Pause Button
⏹️ Stop Button
⏺️ Record Button
⏏️ Eject Button
🎦 Cinema
🔅 Dim Button
🔆 Bright Button
📶 Antenna Bars
📳 Vibration Mode
📴 Mobile Phone Off
♀️ Female Sign
♂️ Male Sign
⚕️ Medical Symbol
♾️ Infinity
♻️ Recycling Symbol
⚜️ Fleur-De-Lis
🔱 Trident Emblem
📛 Name Badge
🔰 Japanese Symbol For Beginner
⭕ Heavy Large Circle
✅ White Heavy Check Mark
☑️ Ballot Box With Check
✔️ Heavy Check Mark
✖️ Heavy Multiplication X
❌ Cross Mark
❎ Cross Mark Button
➕ Heavy Plus Sign
➖ Heavy Minus Sign
➗ Heavy Division Sign
➰ Curly Loop
➿ Double Curly Loop
〽️ Part Alternation Mark
✳️ Eight-Spoked Asterisk
✴️ Eight-Pointed Star
❇️ Sparkle
‼️ Double Exclamation Mark
⁉️ Exclamation Question Mark
❓ Question Mark
❔ White Question Mark
❕ White Exclamation Mark
❗ Exclamation Mark
〰️ Wavy Dash
©️ Copyright
®️ Registered
™️ Trade Mark
#️⃣ Keycap: #
*️⃣ Keycap: *
0️⃣ Keycap: 0
1️⃣ Keycap: 1
2️⃣ Keycap: 2
3️⃣ Keycap: 3
4️⃣ Keycap: 4
5️⃣ Keycap: 5
6️⃣ Keycap: 6
7️⃣ Keycap: 7
8️⃣ Keycap: 8
9️⃣ Keycap: 9
🔟 Keycap: 10
💯 Hundred Points
🔠 Input Latin Uppercase
🔡 Input Latin Lowercase
🔢 Input Numbers
🔣 Input Symbols
🔤 Input Latin Letters
🅰️ A Button (Blood Type)
🆎 Ab Button (Blood Type)
🅱️ B Button (Blood Type)
🆑 Cl Button
🆒 Cool Button
🆓 Free Button
ℹ️ Information
🆔 Id Button
ⓜ️ Circled M
🆕 New Button
🆖 Ng Button
🅾️ O Button (Blood Type)
🆗 Ok Button
🅿️ P Button
🆘 Sos Button
🆙 Up! Button
🆚 Vs Button
🈁 Japanese “Here” Button
🈂️ Japanese “Service Charge” Button
🈷️ Japanese “Monthly Amount” Button
🈶 Japanese “Not Free Of Charge” Button
🈯 Japanese “Reserved” Button
🉐 Japanese “Bargain” Button
🈹 Japanese “Discount” Button
🈚 Japanese “Free Of Charge” Button
🈲 Japanese “Prohibited” Button
🉑 Japanese “Acceptable” Button
🈸 Japanese “Application” Button
🈴 Japanese “Passing Grade” Button
🈳 Japanese “Vacancy” Button
㊗️ Japanese “Congratulations” Button
㊙️ Japanese “Secret” Button
🈺 Japanese “Open For Business” Button
🈵 Japanese “No Vacancy” Button
▪️ Black Small Square
▫️ White Small Square
◻️ White Medium Square
◼️ Black Medium Square
◽ White Medium-Small Square
◾ Black Medium-Small Square
⬛ Black Large Square
⬜ White Large Square
🔶 Large Orange Diamond
🔷 Large Blue Diamond
🔸 Small Orange Diamond
🔹 Small Blue Diamond
🔺 Red Triangle Pointed Up
🔻 Red Triangle Pointed Down
💠 Diamond With A Dot
🔘 Radio Button
🔲 Black Square Button
🔳 White Square Button
⚪ White Circle
⚫ Black Circle
🔴 Red Circle
🔵 Blue Circle
🏁 Chequered Flag
🚩 Triangular Flag
🎌 Crossed Flags
🏴 Black Flag
🏳️ White Flag
🏳️‍🌈 Rainbow Flag
🏴‍☠️ Pirate Flag
🇦🇨 Ascension Island
🇦🇩 Andorra
🇦🇪 United Arab Emirates
🇦🇫 Afghanistan
🇦🇬 Antigua & Barbuda
🇦🇮 Anguilla
🇦🇱 Albania
🇦🇲 Armenia
🇦🇴 Angola
🇦🇶 Antarctica
🇦🇷 Argentina
🇦🇸 American Samoa
🇦🇹 Austria
🇦🇺 Australia
🇦🇼 Aruba
🇦🇽 Åland Islands
🇦🇿 Azerbaijan
🇧🇦 Bosnia & Herzegovina
🇧🇧 Barbados
🇧🇩 Bangladesh
🇧🇪 Belgium
🇧🇫 Burkina Faso
🇧🇬 Bulgaria
🇧🇭 Bahrain
🇧🇮 Burundi
🇧🇯 Benin
🇧🇱 St. Barthélemy
🇧🇲 Bermuda
🇧🇳 Brunei
🇧🇴 Bolivia
🇧🇶 Caribbean Netherlands
🇧🇷 Brazil
🇧🇸 Bahamas
🇧🇹 Bhutan
🇧🇻 Bouvet Island
🇧🇼 Botswana
🇧🇾 Belarus
🇧🇿 Belize
🇨🇦 Canada
🇨🇨 Cocos (Keeling) Islands
🇨🇩 Congo - Kinshasa
🇨🇫 Central African Republic
🇨🇬 Congo - Brazzaville
🇨🇭 Switzerland
🇨🇮 Côte d’Ivoire
🇨🇰 Cook Islands
🇨🇱 Chile
🇨🇲 Cameroon
🇨🇳 China
🇨🇴 Colombia
🇨🇵 Clipperton Island
🇨🇷 Costa Rica
🇨🇺 Cuba
🇨🇻 Cape Verde
🇨🇼 Curaçao
🇨🇽 Christmas Island
🇨🇾 Cyprus
🇨🇿 Czechia
🇩🇪 Germany
🇩🇬 Diego Garcia
🇩🇯 Djibouti
🇩🇰 Denmark
🇩🇲 Dominica
🇩🇴 Dominican Republic
🇩🇿 Algeria
🇪🇦 Ceuta & Melilla
🇪🇨 Ecuador
🇪🇪 Estonia
🇪🇬 Egypt
🇪🇭 Western Sahara
🇪🇷 Eritrea
🇪🇸 Spain
🇪🇹 Ethiopia
🇪🇺 European Union
🇫🇮 Finland
🇫🇯 Fiji
🇫🇰 Falkland Islands
🇫🇲 Micronesia
🇫🇴 Faroe Islands
🇫🇷 France
🇬🇦 Gabon
🇬🇧 United Kingdom
🇬🇩 Grenada
🇬🇪 Georgia
🇬🇫 French Guiana
🇬🇬 Guernsey
🇬🇭 Ghana
🇬🇮 Gibraltar
🇬🇱 Greenland
🇬🇲 Gambia
🇬🇳 Guinea
🇬🇵 Guadeloupe
🇬🇶 Equatorial Guinea
🇬🇷 Greece
🇬🇸 South Georgia & South Sandwich Islands
🇬🇹 Guatemala
🇬🇺 Guam
🇬🇼 Guinea-Bissau
🇬🇾 Guyana
🇭🇰 Hong Kong SAR China
🇭🇲 Heard & McDonald Islands
🇭🇳 Honduras
🇭🇷 Croatia
🇭🇹 Haiti
🇭🇺 Hungary
🇮🇨 Canary Islands
🇮🇩 Indonesia
🇮🇪 Ireland
🇮🇱 Israel
🇮🇲 Isle of Man
🇮🇳 India
🇮🇴 British Indian Ocean Territory
🇮🇶 Iraq
🇮🇷 Iran
🇮🇸 Iceland
🇮🇹 Italy
🇯🇪 Jersey
🇯🇲 Jamaica
🇯🇴 Jordan
🇯🇵 Japan
🇰🇪 Kenya
🇰🇬 Kyrgyzstan
🇰🇭 Cambodia
🇰🇮 Kiribati
🇰🇲 Comoros
🇰🇳 St. Kitts & Nevis
🇰🇵 North Korea
🇰🇷 South Korea
🇰🇼 Kuwait
🇰🇾 Cayman Islands
🇰🇿 Kazakhstan
🇱🇦 Laos
🇱🇧 Lebanon
🇱🇨 St. Lucia
🇱🇮 Liechtenstein
🇱🇰 Sri Lanka
🇱🇷 Liberia
🇱🇸 Lesotho
🇱🇹 Lithuania
🇱🇺 Luxembourg
🇱🇻 Latvia
🇱🇾 Libya
🇲🇦 Morocco
🇲🇨 Monaco
🇲🇩 Moldova
🇲🇪 Montenegro
🇲🇫 St. Martin
🇲🇬 Madagascar
🇲🇭 Marshall Islands
🇲🇰 Macedonia
🇲🇱 Mali
🇲🇲 Myanmar (Burma)
🇲🇳 Mongolia
🇲🇴 Macau SAR China
🇲🇵 Northern Mariana Islands
🇲🇶 Martinique
🇲🇷 Mauritania
🇲🇸 Montserrat
🇲🇹 Malta
🇲🇺 Mauritius
🇲🇻 Maldives
🇲🇼 Malawi
🇲🇽 Mexico
🇲🇾 Malaysia
🇲🇿 Mozambique
🇳🇦 Namibia
🇳🇨 New Caledonia
🇳🇪 Niger
🇳🇫 Norfolk Island
🇳🇬 Nigeria
🇳🇮 Nicaragua
🇳🇱 Netherlands
🇳🇴 Norway
🇳🇵 Nepal
🇳🇷 Nauru
🇳🇺 Niue
🇳🇿 New Zealand
🇴🇲 Oman
🇵🇦 Panama
🇵🇪 Peru
🇵🇫 French Polynesia
🇵🇬 Papua New Guinea
🇵🇭 Philippines
🇵🇰 Pakistan
🇵🇱 Poland
🇵🇲 St. Pierre & Miquelon
🇵🇳 Pitcairn Islands
🇵🇷 Puerto Rico
🇵🇸 Palestinian Territories
🇵🇹 Portugal
🇵🇼 Palau
🇵🇾 Paraguay
🇶🇦 Qatar
🇷🇪 Réunion
🇷🇴 Romania
🇷🇸 Serbia
🇷🇺 Russia
🇷🇼 Rwanda
🇸🇦 Saudi Arabia
🇸🇧 Solomon Islands
🇸🇨 Seychelles
🇸🇩 Sudan
🇸🇪 Sweden
🇸🇬 Singapore
🇸🇭 St. Helena
🇸🇮 Slovenia
🇸🇯 Svalbard & Jan Mayen
🇸🇰 Slovakia
🇸🇱 Sierra Leone
🇸🇲 San Marino
🇸🇳 Senegal
🇸🇴 Somalia
🇸🇷 Suriname
🇸🇸 South Sudan
🇸🇹 São Tomé & Príncipe
🇸🇻 El Salvador
🇸🇽 Sint Maarten
🇸🇾 Syria
🇸🇿 Swaziland
🇹🇦 Tristan da Cunha
🇹🇨 Turks & Caicos Islands
🇹🇩 Chad
🇹🇫 French Southern Territories
🇹🇬 Togo
🇹🇭 Thailand
🇹🇯 Tajikistan
🇹🇰 Tokelau
🇹🇱 Timor-Leste
🇹🇲 Turkmenistan
🇹🇳 Tunisia
🇹🇴 Tonga
🇹🇷 Turkey
🇹🇹 Trinidad & Tobago
🇹🇻 Tuvalu
🇹🇼 Taiwan
🇹🇿 Tanzania
🇺🇦 Ukraine
🇺🇬 Uganda
🇺🇳 United Nations
🇺🇸 United States
🇺🇾 Uruguay
🇺🇿 Uzbekistan
🇻🇦 Vatican City
🇻🇨 St. Vincent & Grenadines
🇻🇪 Venezuela
🇻🇬 British Virgin Islands
🇻🇮 U.S. Virgin Islands
🇻🇳 Vietnam
🇻🇺 Vanuatu
🇼🇫 Wallis & Futuna
🇼🇸 Samoa
🇽🇰 Kosovo
🇾🇪 Yemen
🇾🇹 Mayotte
🇿🇦 South Africa
🇿🇲 Zambia
🇿🇼 Zimbabwe
