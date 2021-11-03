// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

// naming the contract
contract BallotString { 
// We start with the "state" variables (the variable that are saved and show the state of the contract:
// The Voter STRUCT is a template containing what should be collected about a Voter - basically the Voter profile. 
    struct Voter {
        // It has to be a STRUCT because the Voter has many "qualities" attached to it:
        uint weight; 
            // weight is how much voting power the Voter has. 
            // UINT means "unsigned integer", a whole number (no decimals) & with no signs before it (no negative numbers, e.g.-6). 
            // This means only whole numbers from 0 onwards.
        bool voted;  
            // if true, that person already voted. 
            //BOOL stands for boolean, something that is true/false
        address delegate; 
            // If the Voter cannot vote, he/she will delegate to this other Voter's address
        uint vote;
            /** You vote for one of the members of the list (AKA array) of proposals.  E.G. [Maria, Josh, Steph]
            *   Maria's position in the array above is 0
            *       (its a "zero indexed" array - the 1st one is 0)
            *   Josh = 1,
            *   Steph = 2.
            *   If I vote for Josh, I will input his index number of his position in the list of proposals */
    }
    
    // The Proposal STRUCT is a template for what should be collected about a Proposal - basically the Propoal profile. 
    struct Proposal { 
        string name;   // name of the candidate 
        // typically smart contracts do NOT save strings (= text) but save byte1 or byte32 because it is cheaper in gas - cheaper for computations - see this string to bytes32 tool: https://what-if-i-invested.com/str-to-bytes32
        uint voteCount;  // number of accumulated votes
    }
    
    address public chairperson; // this is the person / Ethereum address that is organizing this Ballot - so has special priviledges
    
    mapping(address => Voter) public voters; // this mapping is a list of Voter profiles indexed by their address

    Proposal[] public proposals; // a public list of proposals (Maria, Josh, Steph) called "proposals".  In this case it is basic array - not a list of lists - like a mapping.
    
    // The functions
    constructor(string[] memory proposalNames) { 
        // the CONSTRUCTOR is a special function that deploys the contract. It only runs once.  It sets the inital state of the contract
        //  To run this function needs an array (a list) that will be called proposalNamestext - this array should be composed of strings.
                // Note the word "memory" - its saying this info is temporarily stored - read about the difference between MEMORY and STORAGE here: https://medium.com/cryptologic/memory-and-storage-in-solidity-4052c788ca86
        chairperson = msg.sender; // the CONSTRUCTOR initializes who is the chairperson - the msg.sender - which is the person that deploys this contract.
        voters[chairperson].weight = 1; 
            // this line the chairperson variable is an address.  The voters mapping is indexed by an address.  
            // This is selecting the chairperson's profile in the voters mapping and sets the weight "property" to 1.
            // But the voters[chairperson] - has not been filled out yet... so this is actually inputting part of the chairperson's profile in the voters mapping - ""the key" - the chairperson's address and the weight property in the associated Voter struct.
        
        // this is a "for loop" that does through the proposalNames array and does something to each element in the array
        for (uint i = 0; i < proposalNames.length; i++) {
            proposals.push(Proposal({
                name: proposalNames[i],
                voteCount: 0
            }));
        }
        // this is the expression that 'populates' the proposals array (Proposal[] public proposals). 
        // The 'proposalNames' inserted in the form of an array when "CONSTRUCTING" (constructor(string[] memory proposalNames)) tell the contract to go and populate the 'proposals' array. We
        // also want to make sure that each Proposal starts with a 0 in the voteCount.
        // Here's an article to understand "for" loops in Solidity: https://medium.com/@blockchain101/looping-in-solidity-32c621e05c22
        
    }  // closing bracket of the constructor 

 /** 
     * @dev Give 'voter' the right to vote on this ballot. May only be called by 'chairperson'.
     * @param voter address of voter
     */
    function giveRightToVote(address voter) public { 
        // the function is publicly visible and takes an address that in the function field shows up as 'voter'
        // first requirement :
        require( 
            msg.sender == chairperson, // Only the chairperson can trigger this function
            "Only chairperson can give right to vote." // otherwise it says...
        );
        // second requirement:
        require( 
            !voters[voter].voted, // a voter's "voted" property must be false.  If they had voted - the voters[voter].voted would evaluate to 1.  The "!" turns a 1 to 0.  A true to a false.
            "The voter already voted."
        );
        // third requirement:
        require( 
            voters[voter].weight == 0
        ); // a voter's 'weight' property must be 0 to make sure the person doesn't already have the right to vote
        
        voters[voter].weight = 1; // update the voter's weight property property to 1.
    }
    
    /**
     * @dev Delegate your vote to the voter 'to'.
     * @param to address to which vote is delegated
     */
    function delegate(address to) public { 
        // publicly visible function named delegate, 
        // it takes an address (named "to") (you'll see this var name in the deploy&Run module)
        //The function updates both the delegator
            //  - the voter who is giving their vote to another voter
        // and the delegatee
            //  - the voter who will vote on behalf of another
        
        Voter storage sender = voters[msg.sender]; 
        // creates a new instance of Voter Struct called "sender" and assigns it the Voter struct which is associated with the msg.sender address in the voters mapping
        require(!sender.voted, "You already voted."); // requirement 1: msg.sender can not have alreadyvoted - if it has you get the error "You already voted."
        require(to != msg.sender, "Self-delegation is disallowed."); // requirement 2: 'to' cannot be msg.sender, you cannot delegate a vote to yourself.

        // this loop checks again that the var to is not the msg.sender - in case somehow the 
        while (voters[to].delegate != address(0)) { 
            // while loop: as long as the delegation address is not null
            // the delegate perperty is assigned to the "to" address in the function argument
            to = voters[to].delegate; 
            // We found a loop in the delegation, not allowed.
            require(to != msg.sender, "Found loop in delegation."); // making sure the self delegation ban applies to this while loop too
        }
        //updating the delegator 
        sender.voted = true; // once delegated, the function changes the sender "voted" type to true in the voter's Voter Struct, so (s)he can't vote anymore
        sender.delegate = to; // the "to" argument is an address and it is assigned to the delegate property of the msg.sender's Voter Struct (sender)
        
        //updating the delegatee
        // get the Voter struct of the "to" address 
        // and assign it to a Voter struct named delegate that is stored in storage(long term storage) and not in memory (like RAM)
        Voter storage delegate_ = voters[to]; //
        if (delegate_.voted) {
            // If the delegatee already voted,
            // directly add to the number of votes
            proposals[delegate_.vote].voteCount += sender.weight;
        } else {
            // If the delegatee did not vote yet,
            // add to her weight.
            delegate_.weight += sender.weight;
        }
    }

    /**
     * @dev Give your vote (including votes delegated to you) to proposal 'proposals[proposal].name'.
     * @param proposal index of proposal in the proposals array
     */
    function vote(uint proposal) public { 
        // The vote function takes an integer (of a proposal's index position in the proposals array 
        // and adds to it the vote of the msg.sender (the person who is voting)
        
        // set up a Voter struct called sender - and save this to the blockchain...(I think)
        Voter storage sender = voters[msg.sender];
        
        // The 1st requirement: sender (remember? it's been saved in storage! so this function can access it) must have right to vote
        require(sender.weight != 0, "Has no right to vote"); 
        require(!sender.voted, "Already voted."); // 2nd requirement: sender's "voted" property should be false, otherwise "(s)he has already voted"
        sender.voted = true; // the function in action: sets the sender's "voted" property to "true"
        sender.vote = proposal; // the local variable "proposal" (above) is assigned to the sender's "vote" property

        // If 'proposal' is out of the range of the array,
        // this will throw automatically and revert all
        // changes.
        proposals[proposal].voteCount += sender.weight;
    }

    /** 
     * @dev Computes the winning proposal taking all previous votes into account.
     * @return winningProposal_ index of winning proposal in the proposals array
     */
    function winningProposal() public view // a view function that (see @dev & @return)
            returns (uint winningProposal_) 
    {
        // figuring out who has won: 
        uint winningVoteCount = 0; // creating a new integer variable and set it to 0
        for (uint p = 0; p < proposals.length; p++) { // for loop running through the array of proposals
            if (proposals[p].voteCount > winningVoteCount) {
                winningVoteCount = proposals[p].voteCount;
                winningProposal_ = p; // vote count property of the Proposal Struct
            }
        }
    }

    /** 
     * @dev Calls winningProposal() function to get the index of the winner contained in the proposals array and then
     * @return winnerName_ the name of the winner
     */
    function winnerName() public view // a view function that (see @dev & @return)
            returns (string memory winnerName_)
    {
        winnerName_ = proposals[winningProposal()].name;
    }
}
