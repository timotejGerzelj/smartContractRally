pragma solidity ^0.8.9;
pragma abicoder v2;

contract AudioChat {
    event handleNewAudioChat(uint256 eventTimestamp,
    uint256 createdAt,
    string cid_metadata,
    stateOptions currentState
    );
    event handleAudioChatStateChanged(bytes32 audioEventId, stateOptions newState);
    event handleUpdateMetadataCID(bytes32 audioEventId, string newCid);
    enum stateOptions{ PLANNED, LIVE, CANCELED, PENDING}
    struct CreateAudioChat {
        bytes32 audioEventId;
        uint256 createdAt;
        string cid_metadata;
        stateOptions state;
        address creator;
        uint256 eventTimestamp;
        uint256 listAddressIndex;
        uint256 listStateIndex;
    }


bytes32[] private _ownedIds;
mapping(bytes32 => CreateAudioChat) public idToAudioChat; 
mapping(address => CreateAudioChat[]) public addressToAudioChat;
mapping(stateOptions => CreateAudioChat[]) public stateToAudioChat;
//state will be passed as a string an event is gonna be emitted (handleAudioChatStateChanged)

function createNewAudioChat(
    uint256 eventTimestamp,
    uint256 createdAt,
    string calldata cid_metadata,
    address creator
) external {
    
    bytes32 audioEventId = keccak256(
        abi.encodePacked(
            msg.sender,
            address(this),
            eventTimestamp
        )
    );
    require(idToAudioChat[audioEventId].eventTimestamp == 0, "ALREADY REGISTERED");
    require(eventTimestamp >= createdAt, 'createdAt cannot be greater than eventTimestamp');
    stateOptions currentState;
    uint256 newListAddressIndex;
    if (addressToAudioChat[creator].length == 0){
        newListAddressIndex = 0;
    }
    else {
        newListAddressIndex = addressToAudioChat[creator].length - 1;
    }

    if (eventTimestamp > createdAt){
        currentState = stateOptions.PLANNED;
    }
    else {
        currentState = stateOptions.PENDING;
    }
    uint256 newListStateIndex;
    if (stateToAudioChat[currentState].length == 0){
        newListStateIndex = 0;
    }
    else {
        newListStateIndex = stateToAudioChat[currentState].length + 1;
    }

    require(idToAudioChat[audioEventId].eventTimestamp == 0, "ALREADY REGISTERED");
    
    idToAudioChat[audioEventId] = CreateAudioChat(
        audioEventId,
        createdAt,
        cid_metadata,
        currentState,
        creator,
        eventTimestamp,
        newListAddressIndex,
        newListStateIndex
    );
    addressToAudioChat[creator].push(idToAudioChat[audioEventId]);
    stateToAudioChat[currentState].push(idToAudioChat[audioEventId]);
    _ownedIds.push(audioEventId);

    emit handleNewAudioChat(
        eventTimestamp,
        createdAt,
        cid_metadata,
        currentState
    );
}

function stateChanged(stateOptions newChangedState, bytes32 audioChatId) public {
    uint256 stateListIndex = idToAudioChat[audioChatId].listStateIndex;
    stateOptions previousState = idToAudioChat[audioChatId].state;

    delete stateToAudioChat[previousState][stateListIndex];

    stateToAudioChat[previousState][stateListIndex] = stateToAudioChat[previousState][stateToAudioChat[previousState].length - 1];
    stateToAudioChat[previousState].pop();
    stateToAudioChat[newChangedState].push(idToAudioChat[audioChatId]);
    stateToAudioChat[newChangedState][stateToAudioChat[newChangedState].length - 1].listStateIndex = stateToAudioChat[newChangedState].length - 1;  

    uint256 stateNewListIndex = stateToAudioChat[newChangedState].length - 1;
    idToAudioChat[audioChatId].listStateIndex = stateNewListIndex;
    idToAudioChat[audioChatId].state = newChangedState;
    addressToAudioChat[idToAudioChat[audioChatId].creator][idToAudioChat[audioChatId].listAddressIndex].state = newChangedState;
    addressToAudioChat[idToAudioChat[audioChatId].creator][idToAudioChat[audioChatId].listAddressIndex].listStateIndex = stateNewListIndex;
    emit handleAudioChatStateChanged(audioChatId, newChangedState);
}

function getAudioChatById(bytes32 id) public view returns ( bytes32 audioEventId,
        uint256 createdAt,
        uint256 eventTimestamp,
        string memory cid_metadata,
        stateOptions state,
        address creator
        ) {
    return (idToAudioChat[id].audioEventId, 
    idToAudioChat[id].createdAt,
    idToAudioChat[id].eventTimestamp,
    idToAudioChat[id].cid_metadata,
    idToAudioChat[id].state,
    idToAudioChat[id].creator
    );
}
    function getAllOwnedIds() public view virtual returns (bytes32[] memory) {
        return _ownedIds;
    }


function getAudioChatsByAdress(address creator) public view returns(CreateAudioChat[] memory){
        return addressToAudioChat[creator];
}
function getAudioChatsByState(stateOptions[] memory options) public view returns(CreateAudioChat[] memory){
    uint256 totalSize;
    for (uint256 i; options.length > i; i++){
        totalSize += stateToAudioChat[options[i]].length;
    }
    CreateAudioChat[] memory audioChats = new CreateAudioChat[](totalSize);
    uint256 count = 0;
    for (uint256 i; options.length > i; i++){
        CreateAudioChat[] storage currentAudioChatArr = stateToAudioChat[options[i]];
        for (uint256 ch; currentAudioChatArr.length > ch; ch++){
            audioChats[count] = currentAudioChatArr[ch];
            count++;
        }
    }

    
    return audioChats;
}
}
/*function getAudioChatByAdress(address creator) public view returns(CreateAudioChat[] memory){
        uint256 audioChatLength = addressToAudioChat[creator].length;
        CreateAudioChat[] memory audioChatsToBeSent = new CreateAudioChat[](audioChatLength);
        for (uint i = 0; i < audioChatLength; i++){
            CreateAudioChat storage audioChatToBeSent =  addressToAudioChat[creator][i];
            audioChatsToBeSent[0] = audioChatToBeSent;
        }
        return  addressToAudioChat[creator];
    }
*/

