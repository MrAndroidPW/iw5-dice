/**
    IW5 Roll the Dice.
    Author: Birchy.
    Date: 15/05/2021.

    This is the most modular way I could think of going about such a gamemode.
    Should be easy enough to add additional rolls, as well as unique rolls (Only
    one person can have it at once / has some global effect).
 */

init(){
    dice();
    level thread connect();
}

connect(){
    for(;;){
        level waittill("connected", player);
        player thread spawn();
    }
}

spawn(){
    self endon("disconnect");
    for(;;){
        self waittill("spawned_player");
        self thread roll();
    }
}

roll(){
    self endon("disconnect");
    self endon("death");
    self iprintlnbold("Rolling the dice...");
    value = randomIntRange(1, level.dice[level.dice.size - 1].probability + 1);
    index = binary(value);
    wait 3;
    self iprintlnbold("You rolled " + level.dice[index].name + "!");
    self thread [[level.dice[index].callback]](); 
}

binary(value){
    left = 0;
    right = level.dice.size - 1;
    while(left < right){
        middle = Int(Floor((left + right) * 0.5));
        if(value == level.dice[middle].probability) return middle;
        if(value < level.dice[middle].probability) right = middle - 1;
        else left = middle + 1;
    }
    if(left < level.dice.size - 1 && value > level.dice[left].probability)
        return left + 1;
    return left;
}

register(name, callback, probability){
    roll = spawnstruct();
    roll.name = name;
    roll.callback = callback;
    roll.probability = probability;
    if(level.dice.size != 0) roll.probability += 
        level.dice[level.dice.size - 1].probability;
    level.dice[level.dice.size] = roll;
}

dice(){
    level.dice = [];
    register("AC-130", ::ac130, 1);
    register("JUICED", ::juiced, 1);
}

ac130(){
    self endon("disconnect");
    self endon("death");
    self takeallweapons();
    weapon = "ac130_40mm_mp";
    self giveweapon(weapon);
    self switchtoweapon(weapon);
}

juiced(){
    self endon("disconnect");
    self setmovespeedscale(1.5);
    self waittill("death");
    self setmovespeedscale(1);
}

// for(;;){
//     self setweaponammoclip(weapon, 999);
//     self givemaxammo(weapon);
//     wait 0.05;
// }