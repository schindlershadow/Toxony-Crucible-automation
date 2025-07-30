-- Change these variables to match your input and output chests on the network
local inputChest = "minecraft:barrel_9"
local outputChest = "minecraft:barrel_10"

-- Change this variable to match your fuel items tags
local fuels = { "c:coal", "minecraft:logs", "minecraft:planks" }


-- Do not change anything below this line unless you know what you're doing
local inputs = { "toxony:affinity_fusion_mix", "toxony:poison_paste", "toxony:redstone_mixture" }

local inputInventory = peripheral.wrap(inputChest)
local outputInventory = peripheral.wrap(outputChest)
local names = peripheral.getNames()
local filteredNames = {}

if inputInventory == nil then
    error("Input inventory not found: " .. inputChest)
    return
end

if outputInventory == nil then
    error("Output inventory not found: " .. outputChest)
    return
end

if #names > 0 then
    for i, name in ipairs(names) do
        if string.match(name, "^toxony:copper_crucible.+$") then
            --print("Found matching name: " .. name)
            table.insert(filteredNames, name)
        end
    end
    names = peripheral.getNames()
end

local crucibles = {}
for _, name in ipairs(filteredNames) do
    table.insert(crucibles, peripheral.wrap(name))
end

print("Found " .. #crucibles .. " crucibles.")

-- Helper function to check if an item's tags match any in fuels
local function isFuel(item)
    --print("Checking item: " .. (item and item.name or "nil"))
    if not item or not item.tags then return false end
    for _, fuelTag in ipairs(fuels) do
        if item.tags[fuelTag] then
            return true
        end
    end
    return false
end

-- Helper function to check if an item is a valid input
local function isInput(item)
    if not item then return false end
    for _, inputName in ipairs(inputs) do
        if item.name == inputName then
            return true
        end
    end
    return false
end

-- Check inputInventory and outputInventory for fuel items
local function moveFuelsToCrucibles(inventory, crucible)
    local items = inventory.list()
    for slot, item in pairs(items) do
        if isFuel(inventory.getItemDetail(slot)) then
            -- Try to move to slot 2 of the crucible
            --print("Moving item: " .. item.name .. " from slot " .. slot .. " to crucible")
            crucible.pullItems(peripheral.getName(inventory), slot, 1, 2)
        end
    end
end

-- Move one input item to slot 1 of a crucible with empty slot 1, then move fuel
local function moveInputsAndFuel(inventory, crucibles)
    local items = inventory.list()
    for slot, item in pairs(items) do
        local itemDetail = inventory.getItemDetail(slot)
        if isInput(itemDetail) then
            for _, crucible in ipairs(crucibles) do
                local crucibleItems = crucible.list()
                if not crucibleItems[1] then
                    print("Moving item: " .. itemDetail.name)
                    crucible.pullItems(peripheral.getName(inventory), slot, 1, 1)
                    moveFuelsToCrucibles(inventory, crucible)
                    return -- Only move one input per loop
                end
            end
        end
    end
end

local function cleanCrucibleInputs(crucibles, outputInventory, inputInventory)
    for _, crucible in ipairs(crucibles) do
        local crucibleItems = crucible.list()
        -- If slot 2 has an item but slot 1 does not, move slot 2 item(s) to inputInventory
        if not crucibleItems[1] and crucibleItems[2] then
            --print("Slot 2 has item but slot 1 is empty, moving slot 2 item(s) to inputInventory")
            crucible.pushItems(peripheral.getName(inputInventory), 2)
        end
        -- If slot 1 has an item
        if crucibleItems[1] then
            local itemDetail = crucible.getItemDetail(1)
            local isValidInput = false
            for _, inputName in ipairs(inputs) do
                if itemDetail and itemDetail.name == inputName then
                    isValidInput = true
                    break
                end
            end
            if not isValidInput then
                print("Crafting Completed: " ..
                    (itemDetail and itemDetail.name or "nil"))
                crucible.pushItems(peripheral.getName(outputInventory), 1)
            else
                -- If slot 2 is empty, place a fuel in slot 2
                if not crucibleItems[2] then
                    --print("Slot 2 is empty, placing fuel in crucible")
                    moveFuelsToCrucibles(inputInventory, crucible)
                end
            end
        end
    end
end

print("Startup successful. Monitoring inputChest " .. inputChest .. " and crucibles...")
while true do
    moveInputsAndFuel(inputInventory, crucibles)
    cleanCrucibleInputs(crucibles, outputInventory, inputInventory)
    sleep(1)
end
