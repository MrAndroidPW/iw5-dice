/**
    IW5 Roll the Dice.
    Author: Birchy.
    Date: 15/05/2021.

    This is the most modular way I could think of going about such a gamemode.
    Should be easy enough to add additional rolls, as well as unique rolls (Only
    one person can have it at once / has some global effect).
 */

#include common_scripts\utility;
#include maps\mp\gametypes\_hud_util;

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
    self iprintlnbold("You rolled ^5" + level.dice[index].name + "!");
    self thread [[level.dice[index].callback]](); 
self.ROLLNAMEText = self createFontString( "default", 0.8 );
self.ROLLNAMEText setPoint( "TOP", "RIGHT", "LEFT", "LEFT" ); // It's not moving and we need to pick a good place for this, maybe under the compass. Also can't remove it after death lol.
self.ROLLNAMEText setText("^1Your Roll: ^3 " + level.dice[index].name); 
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

DisablePickingGuns(){ // Not working.
    self waittill( "spawned_player" );
    
    for(;;)
    {
    curwep = self getCurrentWeapon();
    if(self UseButtonPressed())
    {
        wait 1;
        wepchange = self getCurrentWeapon();
        if(curwep != wepchange)
        {
            self DropItem( wepchange );
        }
    }
    wait 1;
}

}

dice(){
    level.dice = [];
    register("AC-130", ::ac130, 1); // working
    register("JUICED", ::juiced, 1); // working
    register("WingsOfRedemption", ::turtle, 1); // working
    register("Hardcore Mode", ::hardcore, 0); // working
    register("3x Health", ::threetimeshp, 0); // working
    register("1 bullet from death", ::oneshot, 1); // working
    register("Finger Gun", ::fingergun, 1); // working
    register("Blinded", ::blind, 0); // not working
    register("No Sprinting", ::nosprint, 1); // working
    register("No Primary", ::noprimary, 1); //working - can pick up weapons.
    register("No Secondary", ::nosecondary, 1); //working - can pick up weapons.
    register("Commando Pro++", ::comandoproplusplus, 0); // Not working
    register("Immune from flash grenades", ::flashimmune, 0); // Not working
    register("Harry Potter", ::harrypotter, 0); // Not working

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

turtle(){
    self endon("disconnect");
    self SetMoveSpeedScale( 0.3 );
    self waittill("death");
    self setmovespeedscale(1);
}


hardcore(){
    self endon("disconnect");
            wait 2;
            self setClientDvar("cg_draw2d", 0); // not setting.
            self.maxhealth = 50;
            self.health = self.maxhealth;
    self waittill("death");
            self.maxhealth = 100;
            self setClientDvar("cg_draw2d", 1);
}

threetimeshp(){
    self endon("disconnect");
            self.maxhealth = 300;
            self.health = self.maxhealth;
    self waittill("death");
            self.maxhealth = 100;
}

oneshot(){
    self endon("disconnect");
            self.maxhealth = 10;
            self.health = self.maxhealth;
    self waittill("death");
            self.maxhealth = 100;
}


fingergun(){
    self endon("disconnect");
            self takeAllWeapons(); 
            self thread DisablePickingGuns(); 
            self giveWeapon( "defaultweapon_mp", 4, false );
            wait 0.25;
            self switchToWeapon("defaultweapon_mp");
}

blind(){
    self endon("disconnect");
            self setClientDvar("r_blur", 3);
    self waittill("death");
            self setClientDvar("r_blur", 3);
}

nosprint(){
    self endon ("disconnect");
            self allowSprint(false);
    self waittill("death");
            self allowSprint(true);
}

noprimary(){ // Not disabling gun pickups.
    self endon ("disconnect");
        self endon("death");
                self thread DisablePickingGuns();
            self takeWeapon(self getCurrentWeapon());
            self switchToWeapon(self.secondaryWeapon);
}

nosecondary(){ 
    self endon ("disconnect");
        self endon("death");
            self thread DisablePickingGuns();
            self takeWeapon(self.secondaryWeapon);
            self switchToWeapon(self.primaryWeapon);
}

comandoproplusplus(){
    self endon("disconnect");
            self setClientDvar( "player_meleeRange", "50000" );
    self waittill("death");
              self setClientDvar( "player_meleeRange", "100" );
}

flashimmune(){
    self endon("disconnect");
            self setClientDvar( "cg_drawShellshock" , "0" );
    self waittill("death");
                self setClientDvar( "cg_drawShellshock" , "1" );    
}

harrypotter(){
    self endon("disconnect");
        self endon("death");
                self iPrintlnBold("^2 MELEE TO GO INVISIBLE FOR 5 SECONDS.");
            wait 2;
            while(1){
            if( self meleeButtonPressed() ) 
            { 
                self hide();
            self iPrintlnBold("INVISIBLE FOR 5 SECONDS");
            wait 5;
            self show();
            self iPrintlnBold("YOU ARE VISIBLE");
            wait 1;
            self iprintlnBold("RECHARGING");
            wait 13; 
            } }
}


// for(;;){
//     self setweaponammoclip(weapon, 999);
//     self givemaxammo(weapon);
//     wait 0.05;
// }