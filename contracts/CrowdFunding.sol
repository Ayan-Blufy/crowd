//SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.5.0 <0.9.0;

contract crowdfunding {
    struct Voter {
        bool voted;
        uint256 Amount;
    }

    mapping(address => Voter) public contributers;
    address public manager;
    uint256 public minimumContribution;
    uint256 public raisedAmount;
    uint256 public noOfContributors;
    uint256 public numRequest;

    struct Request {
        string title;
        string description;
        string image;
        address recipient;
        uint256 target;
        bool completed;
        uint256 noOfVoters;
        uint256 requestid;
        uint256 timestamp;
    }
    mapping(uint256 => address[]) voters;
    Request[] public requests;

    constructor() {
        manager = msg.sender;
        minimumContribution = 1000 wei;
    }

    modifier onlyManager() {
        require(msg.sender == manager, "Only manager can call this function");
        _;
    }

    event RequestPaid(
        string description,
        string image,
        address recipient,
        uint256 target,
        uint256 noOfVoters,
        uint256 indexed timestamp
    );
    event Transcations(
        address indexed contributer,
        uint256 indexed Amount,
        uint256 indexed timestamp
    );

    function sendEth() public payable {
        require(
            msg.value >= minimumContribution,
            "your amount is less than minimumcontribution"
        );
        if (contributers[msg.sender].Amount == 0) {
            noOfContributors++;
            contributers[msg.sender].voted = false;
        }
        raisedAmount += msg.value;
        contributers[msg.sender].Amount += msg.value;

        emit Transcations(msg.sender, msg.value, block.timestamp);
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function vaildForRefund() public view returns (bool) {
        if (contributers[msg.sender].voted == false) {
            return true;
        }

        return false;
    }

    function getAmountDonted() public view returns (uint256) {
        return contributers[msg.sender].Amount;
    }

    function getRefund() public {
        require(
            contributers[msg.sender].Amount > minimumContribution &&
                contributers[msg.sender].voted == false,
            "You are not eligible for refund"
        );

        address payable recipient = payable(msg.sender);

        recipient.transfer(contributers[recipient].Amount);
        raisedAmount -= contributers[recipient].Amount;
        contributers[recipient].Amount = 0;
        noOfContributors--;
    }

    function getAllRequests() public view returns (Request[] memory) {
        return requests;
    }

    function createRequest(
        string memory _title,
        string memory _description,
        string memory _image,
        address _recipient,
        uint256 value
    ) public onlyManager {
        require(_recipient != manager, "this recipient is not allowed");
        require(raisedAmount > value, "Amount for request is too high");
        requests.push(
            Request(
                _title,
                _description,
                _image,
                _recipient,
                value,
                false,
                0,
                numRequest,
                block.timestamp
            )
        );
        numRequest++;

        // emit RequestCreated( numRequest-1,_title,_description,_image,_recipient,value,newRequest.noOfVoters,newRequest.completed,block.timestamp);
    }

    function Checkvoter(uint256 i, address recipient)
        public
        view
        returns (bool)
    {
        address[] memory arr = voters[i];
        for (uint256 j = 0; j < arr.length; j++) {
            if (arr[j] == recipient) {
                return true;
            }
        }
        return false;
    }

    function makeVote(uint256 requestNo) public {
        require(
            contributers[msg.sender].Amount > minimumContribution,
            "You cannot Vote"
        );
        Request storage thisrequest = requests[requestNo];
        require(
            Checkvoter(requestNo, msg.sender) == false,
            "You have already voted"
        );
        require(thisrequest.completed == false, "This request is completed");
        voters[requestNo].push(address(msg.sender));
        contributers[msg.sender].voted = true;
        thisrequest.noOfVoters += 1;
    }

    function makePayment(uint256 _requestNo) public onlyManager {
        Request storage thisRequest = requests[_requestNo];
        require(
            raisedAmount > thisRequest.target,
            "Sorry we don't have enough money"
        );
        require(thisRequest.completed == false, "This request is completed");
        require(
            thisRequest.noOfVoters > noOfContributors / 2,
            "incompelete voting is done"
        );

        address payable to = payable(thisRequest.recipient);
        to.transfer(thisRequest.target);
        thisRequest.completed = true;
        raisedAmount -= thisRequest.target;

        emit RequestPaid(
            thisRequest.description,
            thisRequest.image,
            thisRequest.recipient,
            thisRequest.target,
            thisRequest.noOfVoters,
            block.timestamp
        );
    }
}
