pragma solidity ^0.4.17;

contract ENC {

    address _owner;

    struct User {
        address _walletAddress;
        string _registration;
        uint256 _balance;
    }

    struct Provider {
        uint256 _id;
        address _walletAddress;
        string _type;
    }

    struct LastAction {
        uint256 _id_provider;
        bool _entry; // entry = true; exit = false
        string _registration;
    }


    //-------------------------------------------------------

    mapping(address => User) usersMap;
    mapping(uint256 => Provider) providersMap;
    mapping(string => LastAction) lastActionsMap;
    mapping(string => address) registrationToWallet;
    string userCreated = "Welcome! You have been created";
    string userDisabled = "You have been terminated!";
    string accountHasBeenReplenished = "You have successfully replenished your account";
    string providerCreated = "Provider has been created";
    string userCharged = "User has been charged";
    string userHasEntered = "User has entered";


    //-------------------------------------------------------

    function ENC() {
        _owner = msg.sender;
    }


    //returns user balance
    function userRegistration(string registration) public returns (string) {
        require(bytes(usersMap[msg.sender]._registration).length != 0);
        usersMap[msg.sender] = User({
            _registration: registration,
            _balance: 0,
            _walletAddress: msg.sender
            });
        registrationToWallet[registration] = msg.sender;
        return userCreated;
    }

    function userDisable(string registration) public returns (string){
        require(usersMap[msg.sender]._walletAddress == msg.sender);
        usersMap[msg.sender]._registration = "";
        usersMap[msg.sender]._walletAddress = 0;
        registrationToWallet[registration] = 0;
        return userDisabled;
    }

    function paymentToAccount(string registration, uint amount) public payable returns (string) {
        require(bytes(usersMap[msg.sender]._registration).length != 0); //should fail if userDoesn't exist
        usersMap[msg.sender]._balance = usersMap[msg.sender]._balance + amount;
        return accountHasBeenReplenished;
    }

    //--------------------------------------------------------

    function providerCreation(uint256 id, address providerWallet, string providerType) public returns (string)  {
        require(msg.sender == _owner);
        providersMap[id] = Provider({
            _id: id,
            _walletAddress: providerWallet,
            _type: providerType
            });
        return providerCreated;
    }

    //---------------------------------------------------------

    //Only called when on entry
    function logEntry(uint256 providerId, string registration) public returns (string){
        require(registrationToWallet[registration] != 0); //should fail if userDoesn't exist
        require(lastActionsMap[registration]._entry == false);
        logAction(providerId, true, registration);
        return userHasEntered;
    }

    //Only called when on exit
    function chargeUser(string registration, uint amount, uint256 providerId) public payable returns (string){
        require(registrationToWallet[registration] != 0); //should fail if userDoesn't exist
        require(lastActionsMap[registration]._entry == true);
        require(usersMap[registrationToWallet[registration]]._balance > amount);
        logAction(providerId, false, registration);
        providersMap[providerId]._walletAddress.transfer(amount);
        return userCharged;
    }

    function logAction(uint256 providerId, bool entry, string registration) public{
        lastActionsMap[registration] = LastAction({
            _id_provider: providerId,
            _entry: entry,
            _registration: registration
            });
    }

}