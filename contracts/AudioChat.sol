pragma solidity ^0.8.9;
pragma abicoder v2;

contract AudioChat {
    event handleNewAudioChat(
    bytes32 audio_event_id,
    uint256 start_at,
    uint256 created_at,
    string cid_metadata,
    stateOptions current_state
    );
    event handleaudio_chatstateChanged(bytes32 audio_event_id, stateOptions newState);
    event handleUpdateMetadataCID(bytes32 audio_event_id, string newCid);
    enum stateOptions{ PLANNED, LIVE, CANCELED, PENDING}
    struct CreateAudioChat {
        bytes32 audio_event_id;
        uint256 created_at;
        string cid_metadata;
        stateOptions state;
        address creator;
        uint256 start_at;
        uint256 list_address_index;
        uint256 list_state_index;
    }


bytes32[] private _owned_ids;
mapping(bytes32 => CreateAudioChat) public id_to_audio_chat; 
mapping(address => CreateAudioChat[]) public address_to_audio_chat;
mapping(stateOptions => CreateAudioChat[]) public state_to_audio_chat;
//state will be passed as a string an event is gonna be emitted (handleaudio_chatstateChanged)

function createNewAudioChat(
    uint256 start_at,
    uint256 created_at,
    string calldata cid_metadata,
    address creator
) external {
    
    bytes32 audio_event_id = keccak256(
        abi.encodePacked(
            msg.sender,
            address(this),
            start_at
        )
    );
    require(id_to_audio_chat[audio_event_id].start_at == 0, "ALREADY REGISTERED");
    require(start_at >= created_at, 'created_at cannot be greater than start_at');
    stateOptions current_state;
    uint256 new_list_address_index;
    if (address_to_audio_chat[creator].length == 0){
        new_list_address_index = 0;
    }
    else {
        new_list_address_index = address_to_audio_chat[creator].length - 1;
    }

    if (start_at > created_at){
        current_state = stateOptions.PLANNED;
    }
    else {
        current_state = stateOptions.PENDING;
    }
    uint256 new_list_state_index;
    if (state_to_audio_chat[current_state].length == 0){
        new_list_state_index = 0;
    }
    else {
        new_list_state_index = state_to_audio_chat[current_state].length + 1;
    }

    require(id_to_audio_chat[audio_event_id].start_at == 0, "ALREADY REGISTERED");
    
    id_to_audio_chat[audio_event_id] = CreateAudioChat(
        audio_event_id,
        created_at,
        cid_metadata,
        current_state,
        creator,
        start_at,
        new_list_address_index,
        new_list_state_index
    );
    address_to_audio_chat[creator].push(id_to_audio_chat[audio_event_id]);
    state_to_audio_chat[current_state].push(id_to_audio_chat[audio_event_id]);
    _owned_ids.push(audio_event_id);

    emit handleNewAudioChat(
        audio_event_id,
        start_at,
        created_at,
        cid_metadata,
        current_state
    );
}

function stateChanged(stateOptions new_changed_state, bytes32 audio_chat_id) public {
    uint256 state_list_index = id_to_audio_chat[audio_chat_id].list_state_index;
    stateOptions previous_state = id_to_audio_chat[audio_chat_id].state;

    delete state_to_audio_chat[previous_state][state_list_index];

    state_to_audio_chat[previous_state][state_list_index] = state_to_audio_chat[previous_state][state_to_audio_chat[previous_state].length - 1];
    state_to_audio_chat[previous_state].pop();
    state_to_audio_chat[new_changed_state].push(id_to_audio_chat[audio_chat_id]);
    state_to_audio_chat[new_changed_state][state_to_audio_chat[new_changed_state].length - 1].list_state_index = state_to_audio_chat[new_changed_state].length - 1;  

    uint256 state_new_list_index = state_to_audio_chat[new_changed_state].length - 1;
    id_to_audio_chat[audio_chat_id].list_state_index = state_new_list_index;
    id_to_audio_chat[audio_chat_id].state = new_changed_state;
    address_to_audio_chat[id_to_audio_chat[audio_chat_id].creator][id_to_audio_chat[audio_chat_id].list_address_index].state = new_changed_state;
    address_to_audio_chat[id_to_audio_chat[audio_chat_id].creator][id_to_audio_chat[audio_chat_id].list_address_index].list_state_index = state_new_list_index;
    emit handleaudio_chatstateChanged(audio_chat_id, new_changed_state);
}

function getAudioChatById(bytes32 id) public view returns ( bytes32 audio_event_id,
        uint256 created_at,
        uint256 start_at,
        string memory cid_metadata,
        stateOptions state,
        address creator
        ) {
    return (id_to_audio_chat[id].audio_event_id, 
    id_to_audio_chat[id].created_at,
    id_to_audio_chat[id].start_at,
    id_to_audio_chat[id].cid_metadata,
    id_to_audio_chat[id].state,
    id_to_audio_chat[id].creator
    );
}
    function getAllOwnedIds() public view virtual returns (bytes32[] memory) {
        return _owned_ids;
    }


function getaudio_chatsByAdress(address creator) public view returns(CreateAudioChat[] memory){
        return address_to_audio_chat[creator];
}
function getaudio_chatsByState(stateOptions[] memory options) public view returns(CreateAudioChat[] memory){
    uint256 total_size;
    for (uint256 i; options.length > i; i++){
        total_size += state_to_audio_chat[options[i]].length;
    }
    CreateAudioChat[] memory audio_chats = new CreateAudioChat[](total_size);
    uint256 count = 0;
    for (uint256 i; options.length > i; i++){
        CreateAudioChat[] storage currentAudioChatArr = state_to_audio_chat[options[i]];
        for (uint256 ch; currentAudioChatArr.length > ch; ch++){
            audio_chats[count] = currentAudioChatArr[ch];
            count++;
        }
    }

    
    return audio_chats;
}
}
/*function getAudioChatByAdress(address creator) public view returns(CreateAudioChat[] memory){
        uint256 audioChatLength = address_to_audio_chat[creator].length;
        CreateAudioChat[] memory audio_chatsToBeSent = new CreateAudioChat[](audioChatLength);
        for (uint i = 0; i < audioChatLength; i++){
            CreateAudioChat storage audioChatToBeSent =  address_to_audio_chat[creator][i];
            audio_chatsToBeSent[0] = audioChatToBeSent;
        }
        return  address_to_audio_chat[creator];
    }
*/

