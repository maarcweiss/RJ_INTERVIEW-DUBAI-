
/*
*THIS CODE ONLY HAS TO BE USED IF YOU WANT TO COPY AND PASTE IT IN YOUR REMIX ACCOUNT SO YOU ARE ABLE TO USE THE FUNCTIONS AND EVENTS OF THE CONTRACT
*TO CHECK IF THEY WORK IN A FAMILY FRIENDLY WAY. 
*THIS FILE DO NOT USE FOR ANYTHING ELSE THAN PASTING THE CODE IN REMIX IF YOU WANT TO SEE IT FROM THERE
*THE REAL SAMRT CONTRACT IS IN vWorld.sol not in RemixVWorld.sol
*/


//SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;
//compiler using exactly verison 0.8.15. See in package.json ('solc':)

//import safe practices from openzeppelin
import "github.com/OpenZeppelin/openzeppelin-contracts/contracts/utils/math/SafeMath.sol";
//reentrancyguard will help against reentrancy attacks
import "github.com/OpenZeppelin/openzeppelin-contracts/contracts/security/ReentrancyGuard.sol";

//creation of the main contract
contract vWorld is ReentrancyGuard{

    //protection against underflow and overflow attacks
    using SafeMath for uint;
    
    //this way everybody can see who created the contract
    //keyword immutable used to save gas because it is not saved in storage
    address public immutable owner;

    //See how many areas there are available, in this case if the owner initialized right the contract, there should be 3 
    uint public totalAreasCounter;

    //event to put into sale the areas
    event UpdateSalesStatus(string _msg,uint _cost);
    //area transfer event with indexed keyword to enable to search for the event using indexed parameters as filters
    event Transfer(address indexed _from, address indexed _to, uint _areaID);
    //area Ether Transfer
    event EtherTransfer(address indexed _from, address indexed _to, uint _cost);

    /*
    *mapping to see the past ownerships of the areas. Note that this mapping is very gaswise expensive
    *but for the single contract with 3 areas that we are doing there is no problem. In a bigger project we could 
    *manage to do the same with an event (or log) and the data could be consulted by an external program using javascript
    *insert the areaId as the uint256 and an index of the ownership for the address to appear
    */
    mapping (uint256 => address[]) public area_ownerships;
    
    //you can see the details of the area that you like inserting the area Id(0 to 2).
    mapping(uint256 => Area) public areas; 

    struct Area
    {
        address payable ownerAddress;
        string location;
        uint cost;
        uint areaID;
        bool wantSell;
    }

    modifier onlyOwner
    {
        require(msg.sender == owner);
        _;
    }

    //only the owners of an area will be able to call certain functions
    modifier areaOwner(uint256 _areaID)
    {
        require(areas[_areaID].ownerAddress == msg.sender, "You do not own the area");
        _;
    }
    //initialize the contract
    constructor()ReentrancyGuard(){
        owner = msg.sender;
    }

    //function where the owner of the contract needs to create the areas in the vWorld(not more than 3)
    function createArea(
        //to change status
        //Status _status,
        address payable _ownerAddress,
        string memory _location,
        uint256 _cost,
        uint256 _areaID,
        bool _wantSell
    ) external onlyOwner nonReentrant returns (bool){
        areas[_areaID] = Area(_ownerAddress, _location, _cost, _areaID, _wantSell);
        require(totalAreasCounter < 3, "Not more than 3 ;)");
        //the second part from the require statement uses more or less gas depending on how long the message is
        //we could use a custom error to save some gas there too but I it is not a big deal at the moment.
        totalAreasCounter ++;
        //update the mapping where you can check the past owners
        area_ownerships[_areaID].push(_ownerAddress);
        return true;
    }

    function wantToSellArea(uint _areaId)external nonReentrant areaOwner(_areaId){
        require(_areaId <=2 && _areaId >= 0);
        Area storage area = areas[_areaId];
        //it would not happen nothing important if this require would not be here, but basically it is done to not repeat an action
        //just execute the function if there was not previously desire to sell the area.
        require(area.wantSell == false,"alredy selected");
        area.wantSell = true;
    
        
    }

    function wantToKeepArea(uint _areaId)
        external 
        areaOwner(_areaId) 
        nonReentrant 
    {
        require(_areaId <=2 && _areaId >= 0);
        Area storage area = areas[_areaId];
        //just execute the function if there was previously desire to sell the area.
        require(area.wantSell == true,"alredy selected");
        area.wantSell = false;
    }

    function changeAreaCost(uint256 _areaId, uint256 _newCost)
        external
        areaOwner(_areaId) nonReentrant
    {
        require(_areaId <=2 && _areaId >= 0);
        require(_newCost > 0, "Are you trying to give it for free?");
        areas[_areaId].cost = _newCost;
    }

    //this function will allow the user to buy a area that is alredy being wanted to be sold
    //note there is not a bid system, I assumed that it was needed
    function buyArea(uint256 _areaId) external payable nonReentrant{
        require(_areaId <=2 && _areaId >= 0);
        Area storage area = areas[_areaId];
        //require that the address that wants to buy the area does not alredy own it.
        require(msg.sender != areas[_areaId].ownerAddress, "You alredy own the area");
        //require that the owner wants to sell the area
        require(area.wantSell == true, "This area it is not selling");
        address payable AreaOwner = areas[_areaId].ownerAddress;
        uint AreaPrice = areas[_areaId].cost;
        //transfer the price of the area
        emit EtherTransfer(msg.sender, AreaOwner, AreaPrice);
        //transfer the area
        emit Transfer(AreaOwner, msg.sender, _areaId);
        //return the desire to sell the area to false
        area.wantSell = false;
        //update the owner address so we can see it when we search for the area details
        area.ownerAddress = payable(msg.sender);
        //update the mapping where you can check the past owners
        area_ownerships[_areaId].push(msg.sender);
    }

    /*
    * fallback function because maybe someone calls a function that does not exist or
    * someone sends ether to the contract without calling any function, therefore we could receive the ether.
    */
    fallback() external payable{}

    /*
    *receive is not really needed but is the data from the msg.data is empty
    *the smart contract will trigger receive before than fallback
    */
    receive() external payable{}
}