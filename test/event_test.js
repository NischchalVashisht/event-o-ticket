let Event = artifacts.require('./TestEvent.sol')


contract('Event',function(accounts){
    let contract;
    let contractCreator = accounts[0];
    let benificiary = accounts[1];
    let purchaser = accounts[2];
    let secondPurchaser = accounts[3];

    const ONE_ETH = 1000000000000000000;
    const ERROR_MSG = 'Returned error: VM Exception while processing transaction: revert'; 

    beforeEach(async function(){
        contract =await Event.new(
            'Music',
            100,
            10000000000,
            10,
            benificiary,
            {
                from: contractCreator,
                gas : 5000000
            }

       );
    });
 
    it('contract is initialize',async function(){
        let name = await contract.eventName.call()
        expect(name).to.equal('Music');
    
        let ticketCount = await contract.availableTicket.call()
        expect(ticketCount.toNumber()).to.equal(100);

        let ticketCharge = await contract.ticketAmount.call()
        expect(ticketCharge.toNumber()).to.equal(10000000000);

        let ticketValidity = await contract.eventDeadline.call()
        expect(ticketValidity.toNumber()).to.equal(600);
   
        let address = await contract.eventBenificiary.call()
        expect(address).to.equal(benificiary);
   
    });

    it('Someone purchase ticket',async function(){

        await contract.purchaseTicket(2,{
            value : 20000000000,
            from : purchaser
        });

        let paidAmount = await contract.amount.call(purchaser)
        expect(paidAmount.toNumber()).to.equal(20000000000);
  
    });

    it('cannot purchase after deadline',async function(){
        try {
             await contract.setCurrentTime(601);
             await contract.sendTransaction(2,{
                value : 20000000000,
                from : secondPurchaser
            });
           expect.fail();
        }
        catch(error){

            expect(error.message).to.equal(ERROR_MSG);
        }      
        
    });

    it('collected money paid out ',async function(){
        await contract.purchaseTicket(2,{
            value : 20000000000,
            from : purchaser
        });

        await contract.setCurrentTime(601);
        await contract.finishEvent();

        let initAmount = await web3.eth.getBalance(benificiary);
        await contract.collectAmount({from: contractCreator});
        
        let newBalance =  await web3.eth.getBalance(benificiary);
        expect(newBalance - initAmount).to.equal(19999997952
        );
       
    });


});