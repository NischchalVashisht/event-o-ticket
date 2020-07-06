pragma solidity >=0.4.21 <0.7.0;
pragma experimental ABIEncoderV2;
contract Event {
    
    enum State { Active ,Failed , Completed, PaidOut}
    string public eventName;
    uint public availableTicket;
    uint public  ticketAmount;
    uint public eventDeadline;
    address payable public eventBenificiary;
    State  state;
    mapping(address => uint) public amount;
    mapping(address => uint) public ticketPurchase;
    address owner;
    uint amountCollected;
    
    
    constructor(string memory nameOfEvent, uint ticketCount, uint ticketCharges,
     uint durationInMinute, address payable benificiaryAddress) public {
        eventName = nameOfEvent;
        availableTicket = ticketCount;
        ticketAmount = ticketCharges * 1 wei;
        eventDeadline = currentTime() + durationInMinute * 1 minutes;
        state = State.Active;
        owner = msg.sender;
        eventBenificiary = benificiaryAddress;
    }
    
    function checkState(State pos) internal returns(string memory){
        if(pos==State.Active){return "Active";}
        else if(pos==State.Failed){return "Failed";}
        else if(pos==State.Completed){return "Completed";}
        else {return "PaidOut";}
    }
    
    function getState() public  returns(string memory){
        return checkState(state);
    }

    function currentTime() internal view returns(uint){
        return now;
    }
    
    modifier inState(State expectedState){
        require(state==expectedState,"InvalidState");
        _;
    }
    
    function purchaseTicket(uint numberOfTicket) public payable inState(State.Active){
        
        require(beforeDeadline(),"You are Late. Booking not available anymore");
        require(int(availableTicket - numberOfTicket) >= 0,"Ticket out ");
        require((ticketAmount * numberOfTicket) == msg.value,"Please provide full amount");
        
        amount[msg.sender] += msg.value;
        ticketPurchase[msg.sender] += numberOfTicket;
        amountCollected += msg.value;
        availableTicket -= numberOfTicket;
        
        
        
    }
    
    function beforeDeadline() internal view returns(bool) {
          return currentTime() < eventDeadline ;
     }
    
    function finishEvent() public inState(State.Active) {
        require(msg.sender==owner,"Only owner can change state");
        require(!beforeDeadline(),"Cannot finish Event before timing");
        state = State.Completed;
    }
    
    function collectAmount() public inState(State.Completed) {
        require(msg.sender==owner,"Only owner can collect amount");
        if(eventBenificiary.send(amountCollected)){
            state = State.PaidOut;
        }
        else{
            state = State.Failed;
        }
        
    }
    
    function cancelTicket() public inState(State.Active){
        require(amount[msg.sender] > 0, "No ticket purchases");
        
        uint ticketValues = amount[msg.sender];
        amount[msg.sender] = 0;
        uint temp = ticketPurchase[msg.sender];
        availableTicket += temp;
        if(!msg.sender.send(ticketValues)){
            availableTicket -= temp;
            amount[msg.sender] = ticketValues;
        }
        
    }
    
    function remove() public {
        require(msg.sender==owner,"Only owner can remove contract");
        require(!beforeDeadline(),"Can't remove before event Deadline");
        selfdestruct(eventBenificiary);
    }
}    

