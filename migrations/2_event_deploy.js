let Event = artifacts.require("./Event.sol");

const field= {
    nameOfEvent : "Music",
    ticketCount : 100,
    ticketCharge :10000,
    durationInMinute :1200,
    benificiaryAddress : "0x913Bba611132d7eCdC8091D4d911385E78b14BdF"
  }
module.exports =async function(deployer,accounts){
    await deployer.deploy(Event,field.nameOfEvent,field.ticketCount,field.ticketCharge,field.durationInMinute,field.benificiaryAddress);
}
 