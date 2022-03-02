// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.4.22 <0.9.0;


contract CoinFlip{

    //User Structure 
    struct User{
        uint userBalance;  // Stores Balance of User
        bool userBetStatus; // Shows if user has placed Bet or No
        uint8 userBetOn;     // Stores the user bet either 0 or 1 , 0 for tails and 1 for heads
        uint userBetValue;  // Stores the amount user has betted
        bool intializer;   // Used to give 100 points for new User
    }

    mapping(address => User) public userData;  // Stores User data corresponding to his/her address
    address[] internal userBetadress;          // Stores address of the User who have placed Bet 


    //Event Declaration
    event Winners(address winnerAddress, uint betAmount ); 
    
    // for Generating random Number
    uint256 randNonce = 0; 


    function _placeBet(uint _amountToBet, uint8 _betOn) public{
        //Initally 100 points added to new users balance
        if(userData[msg.sender].intializer== false){
            userData[msg.sender].userBalance = 100;
            userData[msg.sender].intializer= true;
        }
        
        require(_amountToBet <= userData[msg.sender].userBalance, "Not enough balance!!"); 
        require(userData[msg.sender].userBetStatus== false , "You have already placed bet!!");
        
        //Setting the User data 
        userData[msg.sender].userBetValue = _amountToBet;
        userData[msg.sender].userBalance -= _amountToBet;
        userData[msg.sender].userBetOn = _betOn;
        userData[msg.sender].userBetStatus = true;
        userBetadress.push(msg.sender);
    }


    // Function to check if user won the bet
    function _rewardBet() public{
        uint rand = uint(generateRand()); //Random Number Generator Call
        rand = rand%2;                    // Restricting the random number generated to 0 and 1

        for(uint i=0;i<userBetadress.length; i++){
            _checkBets(userBetadress[i], rand);
            
        }
        delete userBetadress;   // Delete the serBetAddress array after the result is annonuced
    }


    // Function to Check Bets and reward the user who have won the Bet
    function _checkBets(address _address, uint _random) private {
        assert(userData[_address].userBetStatus== true);
        
        if(userData[_address].userBetOn == _random){
            userData[_address].userBalance += (userData[_address].userBetValue*2);
            emit Winners(_address,userData[_address].userBetValue);
        } 
        userData[_address].userBetStatus = false;
    }


    // //Random Function Generator taken from Harmony Github
    // function generateRand() private view returns (bytes32 result) {
	// 	bytes32 input;
	// 	assembly {
	// 		let memPtr := mload(0x40)
	// 				if iszero(staticcall(not(0), 0xff, input, 32, memPtr, 32)) {
	// 					invalid()
	// 				}
	// 				result := mload(memPtr)
	// 		}
  	// }


    //Random Function Generator Using Keccak256
    function generateRand() internal returns (uint256) {
        randNonce++;
        return uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender, randNonce)));
    }

}