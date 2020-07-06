pragma solidity >=0.4.21 <0.7.0;
pragma experimental ABIEncoderV2;

import "./Event.sol";

contract TestEvent is Event {
 uint time;

 constructor(string memory nameOfEvent, uint ticketCount, uint ticketCharges,
     uint durationInMinute, address payable benificiaryAddress) Event(nameOfEvent,ticketCount,ticketCharges,
     durationInMinute,benificiaryAddress) public {
     
     }

  function  currentTime()  internal view returns(uint){
     return time;

 }

 function setCurrentTime(uint newTime) public {
     time = newTime;
 }


}