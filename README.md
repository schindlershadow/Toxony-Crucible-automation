# Toxony-Crucible-automation
ComputerCraft automation for Toxony's Crucible. Supports multiple crucibles.

## Setup
Place a computercraft computer with a wired modem 
Place and connect at least 2 items that have inventories to act as the input and output chests with wired modems
Place and connect as many crucibles with wired modems


Run the following on the computercraft computer

`wget https://raw.githubusercontent.com/schindlershadow/Toxony-Crucible-automation/refs/heads/main/startup.lua`

edit the first 2 lines with the network names of the input and output inventories with `nano startup.lua` (you can copy the names in chat by clicking on them)

You can also optionally edit the fuel tags with your own if you wish to use different fuels

then either restart it or type `startup`

Place fuels and items to be crafted in the input inventory

## Operation
The computer will try to find items and fuels that match Crucible recipes from either the input inventory and place outputs in the output inventory

