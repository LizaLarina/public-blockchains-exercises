// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

// Comment this line for deployment outside of Hardhat blockchains.
import "hardhat/console.sol";

// Import BaseAssignment.sol
import "../BaseAssignment.sol";

// Create contract > define Contract Name
contract Assignment2 is BaseAssignment {

    // State: waiting, starting, playing, revealing, finished.
    string private state = "waiting";

    // Game counter
    uint256 private gameCounter = 0;

    // Player
    address private player1;
    address private player2;

    // Decisions
    string private player1Choice;
    string private player2Choice;

    string private player1PlainChoice;
    string private player2PlainChoice;

    // Decision Hashed
    bytes32 private player1HashedChoice;
    bytes32 private player2HashedChoice;

    // max time
    uint256 private maxTimeStart = 10;
    uint256 private maxTimePlay = 10;
    uint256 private maxTimeReveal = 10;

    // block number > starting
    uint256 private blockNumberStart;
    uint256 private blockNumberPlay;
    uint256 private blockNumberReveal;

    // fee
    uint256 private fee = 0.001 ether;

    event Started(uint256 indexed gameCounter, address indexed player1);
    event Playing(uint256 indexed gameCounter, address indexed player1, address indexed player2);
    event Ended(uint256 indexed gameCounter, address indexed winner, int256 indexed gameOutcome);
    
    // constructor(address _validator) BaseAssignment(_validator) {}
    constructor(address _validator) 
        BaseAssignment(0xbb94CBc84004548b9e174955bB4e26a1757cc5C3) 
    {}

    function getState() public view returns (string memory) {
        return state;
    }

    function getGameCounter() public view returns (uint256) {
        return gameCounter;
    }

    function start() public payable returns (uint256) {
        // checkMaxTime();

        require(keccak256(abi.encodePacked(state)) == keccak256(abi.encodePacked("waiting")) || keccak256(abi.encodePacked(state)) == keccak256(abi.encodePacked("starting")), "Status should be either 'waiting' or 'starting'");
        require(msg.sender != player1, "Error");
        require(msg.value == fee, "To start the game fee is required");

    
        if ((player1 == address(0)) 
            || (keccak256(abi.encodePacked(state)) == keccak256(abi.encodePacked("starting")) && checkMaxTime())) {
            reset();
            player1 = msg.sender;
            state = "starting";
            gameCounter += 1;
            emit Started(gameCounter, player1);
            return 1;
        } else if (player2 == address(0)) {
            player2 = msg.sender;
            state = "playing";
            emit Playing(gameCounter, player1, player2);
            blockNumberPlay = getBlockNumber();
            return 2;
        }

    }

    // function play(string memory choice) public virtual {

    //     require(keccak256(abi.encodePacked(state)) == keccak256(abi.encodePacked("playing")), "Status should be 'playing'");
    //     require(msg.sender == player1 || msg.sender == player2);

    //     if (bytes(player1Choice).length == 0 && bytes(player2Choice).length == 0 ) {
    //         if (msg.sender == player1){
    //             player1Choice = choice;
    //         } else {
    //             player2Choice = choice;
    //         }
    //     }
    // }

    function play(string memory choice) public payable returns (int256) {

        checkMaxTime();
        require(keccak256(abi.encodePacked(state)) == keccak256(abi.encodePacked("playing")), "The game is not in the 'playing' state");
        require(msg.sender == player1 || msg.sender == player2, "You are not authorized to make a move in this game");
        
        if (msg.sender == player1) {
            require(bytes(player1Choice).length == 0, "You have already submitted your choice");
            require(keccak256(abi.encodePacked(choice)) == keccak256(abi.encodePacked("rock")) ||
                    keccak256(abi.encodePacked(choice)) == keccak256(abi.encodePacked("paper")) ||
                    keccak256(abi.encodePacked(choice)) == keccak256(abi.encodePacked("scissors")), "Invalid choice, only rock, paper and scissors are allowed");
            player1Choice = choice;
        } else if (msg.sender == player2) {
            require(bytes(player2Choice).length == 0, "You have already submitted your choice");
            require(keccak256(abi.encodePacked(choice)) == keccak256(abi.encodePacked("rock")) ||
                    keccak256(abi.encodePacked(choice)) == keccak256(abi.encodePacked("paper")) ||
                    keccak256(abi.encodePacked(choice)) == keccak256(abi.encodePacked("scissors")), "Invalid choice, only rock, paper and scissors are allowed");
            player2Choice = choice;
        }

        if (bytes(player1Choice).length == 0 || bytes(player2Choice).length == 0 ) {
            emit Ended(gameCounter, address(0), 0);
            return -1;
        }
        if (bytes(player1Choice).length != 0 && bytes(player2Choice).length != 0 ) {
            // Compute the outcome
            int256 result = 0;
            if (keccak256(abi.encodePacked(player1Choice)) == keccak256(abi.encodePacked(player2Choice))) {
                result = 0; // Draw
            } else if (keccak256(abi.encodePacked(player1Choice)) == keccak256(abi.encodePacked("rock")) && keccak256(abi.encodePacked(player2Choice)) == keccak256(abi.encodePacked("scissors")) ||
                    keccak256(abi.encodePacked(player1Choice)) == keccak256(abi.encodePacked("paper")) && keccak256(abi.encodePacked(player2Choice)) == keccak256(abi.encodePacked("rock")) ||
                    keccak256(abi.encodePacked(player1Choice)) == keccak256(abi.encodePacked("scissors")) && keccak256(abi.encodePacked(player2Choice)) == keccak256(abi.encodePacked("paper"))) {
                result = 1; // Player 1 wins
                emit Ended(gameCounter, player1, 1);
                sendViaCall(payable(player1), address(this).balance);
            } else {
                result = 2; // Player 2 wins
                emit Ended(gameCounter, player2, 2);
                sendViaCall(payable(player2), address(this).balance);
            }

            // Reset the game
            reset();

            return result;
        }
    }

    // Send ether using low-level call().
    function sendViaCall(address payable _to, uint256 _amount) private {
        (bool sent, bytes memory data) = _to.call{value: _amount}("");
        require(sent, "Failed to send Ether");
    }

    function setMaxTime(string memory action, uint256 maxTime) public {

        require(keccak256(abi.encodePacked(state)) == keccak256(abi.encodePacked("waiting")), 
            "Game is not in waiting state");

        require(keccak256(bytes(action)) == keccak256(bytes("start")) 
            || keccak256(bytes(action)) == keccak256(bytes("play")) 
            || keccak256(bytes(action)) == keccak256(bytes("reveal")), "Invalid action");
        if (keccak256(bytes(action)) == keccak256(bytes("start"))) {
            maxTimeStart = maxTime;
        } else if (keccak256(bytes(action)) == keccak256(bytes("play"))) {
            maxTimePlay = maxTime;
        } else if (keccak256(bytes(action)) == keccak256(bytes("reveal"))) {
            maxTimeReveal = maxTime;
        }
    }

    function checkMaxTime() public returns (bool) {
        if (keccak256(abi.encodePacked(state)) == keccak256(abi.encodePacked("starting"))) {
            if (getBlockNumber() > blockNumberStart + maxTimeStart) {
                state = "waiting";
                address payable p1 = payable(player1);
                player1 = address(0);
                p1.transfer(fee);
                emit Ended(gameCounter, address(0), -1);
                reset();
                return true;
            }
        } else if (keccak256(abi.encodePacked(state)) == keccak256(abi.encodePacked("playing"))) {
            if (getBlockNumber() > blockNumberPlay + maxTimePlay) {
                state = "waiting";
                address payable winner;
                if (bytes(player1Choice).length != 0) {
                    winner = payable(player1);
                    winner.transfer(address(this).balance);
                }
                if (bytes(player2Choice).length != 0) {
                    winner = payable(player2);
                    winner.transfer(address(this).balance); // fee or balance?
                }
                // if ((bytes(player2Choice).length == 0) && (bytes(player2Choice).length == 0)) {
                //     return true;
                // }
                emit Ended(gameCounter, address(0), -1);
                reset();
                return true;
            }
        } else if (keccak256(abi.encodePacked(state)) == keccak256(abi.encodePacked("revealing"))) {
            if (getBlockNumber() > blockNumberReveal + maxTimeReveal) {
                state = "waiting";
                address payable winner;
                if (bytes(player1PlainChoice).length != 0) {
                    winner = payable(player1);
                    winner.transfer(address(this).balance);
                }
                if (bytes(player2PlainChoice).length != 0) {
                    winner = payable(player2);
                    winner.transfer(address(this).balance); // fee or balance?
                }
                // if ((bytes(player2Choice).length == 0) && (bytes(player2Choice).length == 0)) {
                // }
                emit Ended(gameCounter, address(0), -1);
                reset();
                return true;
            }
        }
        return false;
    }

    function reset() private {
        // Set to waiting state
        state = "waiting";

        // Reset game
        player1 = address(0);
        player2 = address(0);

        // Reset choices
        player1Choice = "";
        player2Choice = "";

        player1PlainChoice = "";
        player2PlainChoice = "";

        // Reset hashed choices
        player1HashedChoice = 0;
        player2HashedChoice = 0;

        // Reset block numbers
        blockNumberStart = getBlockNumber();
        blockNumberPlay = getBlockNumber();
        blockNumberReveal = getBlockNumber();
    }

    function forceReset() public {
        require(isValidator(msg.sender), "You are not a validator");

        reset();
    }

    function playPrivate(bytes32 hashedChoice) public {
        // checkMaxTime();
        require(keccak256(abi.encodePacked(state)) == keccak256(abi.encodePacked("playing")), "Status should be 'playing'");
        require(msg.sender == player1 || msg.sender == player2, "You are not authorized to make a move in this game");
        if (msg.sender == player1) {
            require(player1HashedChoice == bytes32(0), "You have already submitted your choice");
            player1HashedChoice = hashedChoice;
        } else {
            require(player2HashedChoice == bytes32(0), "You have already submitted your choice");
            player2HashedChoice = hashedChoice;
        }

        if (player1HashedChoice != bytes32(0) && player2HashedChoice != bytes32(0)) {
            state = "revealing";
            // blockNumberReveal = getBlockNumber();
        } 
    }

    function reveal(string memory plainChoice, string memory seed) public payable returns (int256) {
        if (checkMaxTime() == true) {
            emit Ended(gameCounter, address(0), 0);
            return -1;
        }
        require(keccak256(abi.encodePacked(state)) == keccak256(abi.encodePacked("revealing")), "Status should be 'revealing'");
        require(msg.sender == player1 || msg.sender == player2, "Only registered players can call this function");

        bytes32 hashedChoice;
        if (msg.sender == player1) {
            hashedChoice = keccak256(abi.encodePacked(string.concat(seed, "_", plainChoice)));
            require(hashedChoice == player1HashedChoice, "The hashed choice does not match");
            player1PlainChoice = plainChoice;
        } else {
            hashedChoice = keccak256(abi.encodePacked(string.concat(seed, "_", plainChoice)));
            require(hashedChoice == player2HashedChoice, "The hashed choice does not match");
            player2PlainChoice = plainChoice;
        }

        if (bytes(player1PlainChoice).length == 0 || bytes(player2PlainChoice).length == 0 ) {
            emit Ended(gameCounter, address(0), 0);
            return -1;
        }
        if (bytes(player1PlainChoice).length != 0 && bytes(player2PlainChoice).length != 0) {

            int256 result = 0;
            if (keccak256(abi.encodePacked(player1PlainChoice)) == keccak256(abi.encodePacked(player2Choice))) {
                result = 0; // Draw
            } else if (keccak256(abi.encodePacked(player1PlainChoice)) == keccak256(abi.encodePacked("rock")) && keccak256(abi.encodePacked(player2PlainChoice)) == keccak256(abi.encodePacked("scissors")) ||
                    keccak256(abi.encodePacked(player1PlainChoice)) == keccak256(abi.encodePacked("paper")) && keccak256(abi.encodePacked(player2PlainChoice)) == keccak256(abi.encodePacked("rock")) ||
                    keccak256(abi.encodePacked(player1PlainChoice)) == keccak256(abi.encodePacked("scissors")) && keccak256(abi.encodePacked(player2PlainChoice)) == keccak256(abi.encodePacked("paper"))) {
                result = 1; // Player 1 wins
                emit Ended(gameCounter, player1, 1);
                sendViaCall(payable(player1), address(this).balance);
            } else {
                result = 2; // Player 2 wins
                emit Ended(gameCounter, player2, 2);
                sendViaCall(payable(player2), address(this).balance);
            }

            // Reset the game
            reset();

            return result;
        }

    }


    /*=============================================
    =            HELPER METHOD            =
    =============================================*/

    // Hint:
    // https://docs.soliditylang.org/en/latest/abi-spec.html
    // https://ethereum.stackexchange.com/questions/119583/when-to-use-abi-encode-abi-encodepacked-or-abi-encodewithsignature-in-solidity

    function checkRevealed(string memory seed, string memory plainChoice, bytes32 hashedChoice)
        public
        view
        returns (bool)
    {
       
        string memory concatString = string.concat(seed, "_", plainChoice);

        console.log(concatString);

        bytes32 hashedConcatString = keccak256(abi.encodePacked(concatString));

        // console.logBytes32(hashedConcatString);

        return hashedConcatString == hashedChoice;
    }

    /*=====  End of HELPER  ======*/
}
