const hre = require("hardhat");
const { expect } = require('chai').expect;
const assert = require("chai").assert;

/*contract('AudioChat', (chats) => {
  let audio;

  // build up and tear down a new Casino contract before each test
  beforeEach(async () => {
      audio = await Casino.new({ from: fundingAccount });
      await casino.fund({ from: fundingAccount, value: fundingSize });
      assert.equal(await web3.eth.getBalance(casino.address), fundingSize);
  });

  afterEach(async () => {
      await casino.kill({ from: fundingAccount });
  });
}
*/

describe('Test creation of our Contracts', async () => {


  it('Test where the exception should be thrown if eventTimestamp < createdAt', async () => {
      const AudioChat = await ethers.getContractFactory('AudioChat');
      const c = await AudioChat.deploy();  
      let eventTimestamp = 1718926100;
      let cid_metadata = "";
      let creator = "0x391A757Ac409635f05c40e0dc6B80544C2E3B9b6";
    let createdAtGreater = 1718926200;
     await expect(c.createNewAudioChat(
      eventTimestamp,
      createdAtGreater,
      cid_metadata,
      creator
     )).to.be.revertedWith('createdAt cannot be greater than eventTimestamp');
  });
  
  it('Test if the AudioChat is successfully created when passed eventTimestamp > createdAt', async () => {    
    const AudioChat = await ethers.getContractFactory('AudioChat');
    const c = await AudioChat.deploy();  
    let eventTimestamp = 1718926200;
    let cid_metadata = "";
    let creator = "0x391A757Ac409635f05c40e0dc6B80544C2E3B9b6";
    let createdAt = 1718926200;
    await expect(c.createNewAudioChat(
     eventTimestamp,
     createdAt,
     cid_metadata,
     creator
    )
 
    )});
});

describe('Test state changes depending on the createdAt and eventTimestamp', async () =>{
  it('createdAt === eventTimestamp', async () => {
    const AudioChat = await ethers.getContractFactory('AudioChat');
    const c = await AudioChat.deploy(); 
    let eventTimestamp = 1718926200;
    let createdAt = 1718926200;
    expect(await c.stateChanged(
      eventTimestamp,createdAt
     )).to.equal('PENDING');
  });
  it('createdAt < eventTimestamp', async () => {
    const AudioChat = await ethers.getContractFactory('AudioChat');
    const c = await AudioChat.deploy(); 
    let eventTimestamp = 1718926300;
    let createdAt = 1718926200;
    expect(await c.stateChanged(
      eventTimestamp,createdAt
     )).to.equal('PLANNED');
  });

});
  
/*
  it('Test where the eventTimestamp < createdAt is true', async () => {
    const MyContract = await ethers.getContractFactory('AudioChat');
    let eventTimestamp = 1718926100;
    let createdAt = 1718926200;
    let cid_metadata = "";
    let creator = "0x391A757Ac409635f05c40e0dc6B80544C2E3B9b6";
    const contract = await MyContract.deploy();
    await contract.deployed();
    
    await expect(contract.createNewAudioChat()).to.be.revertedWith('createdAt cannot be greater than eventTimestamp');
});
*/



/*
const main = async () => {
  const rsvpContractFactory = await hre.ethers.getContractFactory("AudioChat");
  const rsvpContract = await rsvpContractFactory.deploy();
  await rsvpContract.deployed();
  const [deployer, address1, address2] = await hre.ethers.getSigners();
  let eventTimestamp = 1718926230;
  let createdAt = 1718926200;
  let cid_metadata = "";
  let creator = "0x391A757Ac409635f05c40e0dc6B80544C2E3B9b6";

  let txnCreatedAtLesser = await rsvpContract.createNewAudioChat(
    eventTimestamp,
    createdAt,
    cid_metadata,
    creator
  );
  let wait = await txnCreatedAtLesser.wait();
  console.log("EVENT CREATED createdAt < eventTimestamp", wait.events[0].event, wait.events[0].args);

  let eventID = wait.events[0].args.eventID;
  console.log("EVENT ID:", eventID);

  let eventTimestampAtGreater = 1718926100;



  console.log("EVENT ID:", eventID);
  let eventTimestampAtEqual = 1718926200;

  let txnCreatedAtEqual = await rsvpContract.createNewAudioChat(
    eventTimestampAtEqual,
    createdAt,
    cid_metadata,
    creator
  );

  console.log("EVENT CREATED createdAt == eventTimestamp", wait.events[0].event, wait.events[0].args);

  let eventID3 = wait.events[0].args.eventID;
  console.log("EVENT ID:", eventID);


};

const runMain = async () => {
  try {
    await main();
    
    process.exit(0);
  } catch (error) {
    console.log(error);
    process.exit(1);
  }
};

runMain();*/