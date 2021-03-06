-- * Creates invisible button onload, hidden under the "REFILL" on the deck pad
function onLoad()
    self.createButton({
        click_function="click_refillDeck", function_owner=self,
        position={0,0.1,-1.12}, height=200, width=620, color={1,1,1,0}
    })

    --This is how I found the positions to check for cards
    --That GUID was a card I put on it
    --local pos = self.positionToLocal(getObjectFromGUID("a6b1bd").getPosition())
    --print(pos.x)
    --print(pos.y)
    --print(pos.z)

    --Local positions for each pile of cards
    pos_discard = {-0.957, 0.178, 0.222}
    pos_draw = {0.957, 0.178, 0.222}

    --This is which way is face down for a card or deck relative to the tool
    rot_offset = {x=0, y=0, z=180}
end

-- * Activates when button is clicked
function click_refillDeck()
    --This gets all decks and cards in the discard area
    local discardItemList = findObjectsAtPosition(pos_discard)
    --This is where we want to put those discarded cards
    local pos = self.positionToWorld(pos_draw)
    --This is how we want the card rotated
    local rot = self.getRotation()
    rot = {rot.x+rot_offset.x, rot.y+rot_offset.y, rot.z+rot_offset.z}

    --This is going through and placing all llcards/decks with this info
    for _, obj in ipairs(discardItemList) do
        obj.setPositionSmooth(pos, false, true)
        obj.setRotationSmooth(rot)
    end

    --We check if any cards were moved before we go to shuffle
    if #discardItemList > 0 then
        --Finally, we start a short timer to shuffle the cards after they move
        Timer.destroy("shuffleTimer_"..self.getGUID())
        Timer.create({
            identifier = "shuffleTimer_"..self.getGUID(),
            function_name = "timer_shuffle",
            function_owner = self,
            delay = 1
        })
    end
end

-- * This is used by another function to locate information on what is in an area
function findObjectsAtPosition(localPos)
    --We convert that local position to a global table position
    local globalPos = self.positionToWorld(localPos)
    --We then do a raycast of a sphere on that position to find objects there
    --It returns a list of hits which includes references to what it hit
    local objList = Physics.cast({
        origin=globalPos, --Where the cast takes place
        direction={0,1,0}, --Which direction it moves (up is shown)
        type=2, --Type. 2 is "sphere"
        size={2,2,2}, --How large that sphere is
        max_distance=1, --How far it moves. Just a little bit
        debug=false --If it displays the sphere when casting.
    })

    --Now we have objList which contains any and all objects in that area.
    --But we only want decks and cards. So we will create a new list
    local decksAndCards = {}
    --Then go through objList adding any decks/cards to our new list
    for _, obj in ipairs(objList) do
        if obj.hit_object.tag == "Deck" or obj.hit_object.tag == "Card" then
            table.insert(decksAndCards, obj.hit_object)
        end
    end

    --Now we return this to where it was called with the information
    return decksAndCards
end

-- * Activated by a timer to shuffle deck
function timer_shuffle()
    --This uses our findObjects function to find the deck in in the draw area
    local discardItemList = findObjectsAtPosition(pos_draw)
    --We should only have 1 item here, and it should be a deck
    --But just in case, we will go through any and all returns
    for _, obj in ipairs(discardItemList) do
        --Final check to make sure its a deck we're trying to shuffle
        if obj.tag == "Deck" then
            obj.shuffle()
        end
    end
end
