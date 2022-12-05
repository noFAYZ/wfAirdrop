const express = require('express')
const Moralis = require("moralis").default
const { EvmChain } = require("@moralisweb3/evm-utils")
const cron = require('node-cron');
const fs = require('fs');
//const holderslist = require("./holders.json")
//const holdersAddresses = require("./holdersAddresses.json")
//const holdersAmount = require("./holdersAmount.json")

const {Storage} = require('@google-cloud/storage');
const storage = new Storage();


const app = express()
const port = process.env.PORT || 3000
const cronJobs = [];
const BUCKET_NAME = "hwmct"


const MORALIS_API_KEY = "LKwVLPKaOwISXAZqApxkns2ENMhRgIQAmxhz7ks0JH8amyOkIjRpb9WBKLSx1tSu"
const address = "0xCe8A6E03e6996f259191a18c4E2Aa398319b04E9"
const chain = EvmChain.POLYGON
const total = 5000;


async function getHolders(cursor) {
    return await Moralis.EvmApi.nft.getNFTOwners({
    address,
    chain,
    cursor,
});


}

function freq(nums) {
  return nums.reduce((acc, curr) => {
    acc[curr] = -~acc[curr];
    return acc;
  }, {});
}

function sleep(ms) {
  return new Promise((resolve) => {
    setTimeout(resolve, ms);
  });
}

const allHolders = async ()=>{

  try {

    let i=0;
    let j=0;
    let fetched = 0;
    let pages = []
    let cursors = []
    let NftHolders = []
    let NftHoldersAmount =[]

    let finalHoldersAddresses =[]
    let finalHoldersAmount =[]



    let page = await getHolders()
    cursors.push(page.data.cursor)
    pages.push(page.data)
    fetched += page.data.page_size
    page.result.map((e, i)=>{
      NftHolders.push(e.ownerOf._value)
    })
    

  while(fetched != total){
      console.log("Total Fetched: " + fetched + '/' + total)
      // Get and return the crypto data
      page = await getHolders(cursors[i])
      cursors.push(page.data.cursor)
      pages.push(page.data)
      

      page.result.map((e, i)=>{
        NftHolders.push(e.ownerOf._value)
      })

      fetched += page.data.page_size
      i+=1
      await sleep(1000);
    }

    let count = freq(NftHolders);

    for (let [key, value] of Object.entries(count)) {
      finalHoldersAddresses.push(key)
      finalHoldersAmount.push(value)
      console.log(`${key}, ${value}`);
    }

  /*
    fs.writeFile("holders.json", JSON.stringify(pages), 'utf8', function (err) {
      if (err) {
          console.log("An error occured while writing JSON Object to File.");
          return console.log(err);
      }
   
      console.log("JSON file has been saved.");
    });
    fs.writeFile("holdersAddresses.json", JSON.stringify(finalHoldersAddresses), 'utf8', function (err) {
      if (err) {
          console.log("An error occured while writing JSON Object to File.");
          return console.log(err);
      }
  
      console.log("JSON file has been saved.");
    });
    fs.writeFile("holdersAmount.json", JSON.stringify(finalHoldersAmount), 'utf8', function (err) {
      if (err) {
          console.log("An error occured while writing JSON Object to File.");
          return console.log(err);
      }

      console.log("JSON file has been saved.");
    });

*/

//WRITE DATA TO FILES ON GCLOUD BUCKET
    await writeFileToCloudStorage("holders.json",pages)
    await writeFileToCloudStorage("holdersAddresses.json",finalHoldersAddresses)
    await writeFileToCloudStorage("holdersAmount.json",finalHoldersAmount)



  } catch (error) {
    // Handle errors
    console.error(error)

  }

}



// GCLOUD Storage 

async function createBucket() {
  // Creates the new bucket
  await storage.createBucket(BUCKET_NAME);
  console.log(`Bucket ${BUCKET_NAME} created.`);
}



async function readFilefromCloudStorage(FILE_NAME) {
  const contents = await storage.bucket(BUCKET_NAME).file(FILE_NAME).download();
  return JSON.parse(contents);
}

async function writeFileToCloudStorage(FILE_NAME, contents) { 
  try {
    await storage.bucket(BUCKET_NAME).file(FILE_NAME).save(JSON.stringify(contents));
  } catch(e) {
     console.log(e);
 }
}



//Routes

app.get('/', async (req, res) => {
    try {

        const holderslist = await readFilefromCloudStorage("holders.json")
        
        res.status(200)
        let objj = {"end": "Addresses",
                    "holders": holderslist}
        res.json(JSON.stringify(objj))
      } catch (error) {
        // Handle errors
        console.error(error)
        res.status(500)
        res.json({ error: error.message })
      }
})

app.get('/getHoldersAddresses', async (req, res) => {
  try {
    const holdersAddresses = await readFilefromCloudStorage("holdersAddresses.json")
    console.log(holdersAddresses.length)
    var half_length = Math.ceil(holdersAddresses.length / 8);    

    var leftSide = holdersAddresses.slice(0,half_length);
      res.status(200)
      let objj = {data: leftSide,
        no: 2
      }
res.json(objj)
      //res.send(holdersAddresses)
      
    } catch (error) {
      // Handle errors
      console.error(error)
      res.status(500)
      res.json({ error: error.message })
    }
})

app.get('/getHoldersAmount', async (req, res) => {
  try {
    const holdersAmount = await readFilefromCloudStorage("holdersAmount.json")

    let objj = {data: holdersAmount,
      no: 2
    }
      
      res.status(200)
      res.json(objj)
      
    } catch (error) {
      // Handle errors
      console.error(error)
      res.status(500)
      res.json({ error: error.message })
    }
})
app.get('/crons', async (req, res) => {
  try {

      
      
      res.status(200)
      res.json(cronJobs)
    } catch (error) {
      // Handle errors
      console.error(error)
      res.status(500)
      res.json({ error: error.message })
    }
})


// Cron Job

const job = cron.schedule("0 */15 * * * * ", async ()=>{ console.log('running on Job');
await allHolders()});


const startServer = async () => {
    await Moralis.start({
      apiKey: MORALIS_API_KEY,
    })

    app.listen(port, () => {
      console.log(`Example app listening on port ${port}`)
    })    

    

    await job.start()
    cronJobs.push(job)

  }
  
  startServer()