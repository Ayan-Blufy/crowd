import React, { useEffect, useState } from 'react'
import Card from '../components/Card'
import Navbar from '../components/Navbar'
import { ethers } from 'ethers';

import Crowdfunding from "../artifacts/contracts/CrowdFunding.sol/crowdfunding.json";

const MainRequests = ({manager}) => {


  const [Array, setArray] = useState([]);

  useEffect(() => {


    async function solve() {
      try {

        const provider = new ethers.providers.JsonRpcProvider('https://eth-goerli.g.alchemy.com/v2/Qo1DxQ8U6Hzw3Da7p3n7zTlD0xUgMR4t');
        const contract = new ethers.Contract(process.env.NEXT_PUBLIC_ADDRESS, Crowdfunding.abi, provider);

        const arr = await contract.getAllRequests();
    
       
        const Data = arr.map((ele,i) => {
          return {
            requestNo: parseInt(ele?.requestid),
            title: ele?.title,
            story: ele?.description,
            image: ele?.image,
            amount: ethers.utils.formatEther(ele?.target),
            recipient: ele?.recipient,
            voters: parseInt(ele ?.noOfVoters),
            requestaddress: ele?.image,
            completed: ele?.completed
          }
        })
        
        

      
    

        setArray(Data);


      } catch (err) {
        console.log(err);
      }
    }


    solve();

  }, [])



  return (
    <>
      <div className='gradient-bg-services min-h-screen p-2'>
        <Navbar manager={manager} />
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 place-items-center mb-20 w-full gap-3 mx-auto">

          {Array?.map((ele) => {
            return (
              <Card title={ele?.title} amount={ele?.amount} story={ele.story} voters={ele.voters} address={ele.recipient} image={ele.image} requestaddress={ele.requestaddress} />
            )

          }

          )}

        </div>

      </div>

    </>
  )
}

export default MainRequests

export async function getStaticProps() {

  const provider = new ethers.providers.JsonRpcProvider("https://eth-goerli.g.alchemy.com/v2/Qo1DxQ8U6Hzw3Da7p3n7zTlD0xUgMR4t");
  const contract = new ethers.Contract(process.env.CONTRACT_ADDRESS, Crowdfunding.abi, provider);

  const manager = await contract.manager();




  return {
    props: {
      manager

    }
  }
}
