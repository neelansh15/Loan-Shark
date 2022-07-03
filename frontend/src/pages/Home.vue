<script lang="ts" setup>
import Navbar from '../components/Navbar.vue'
import { Jazzicon } from 'vue-connect-wallet'
import { useStore } from '../store/useStore'
import { storeToRefs } from 'pinia';
import { ethers } from 'ethers'
import { formatEther } from 'ethers/lib/utils';
import { onMounted, reactive, watch } from 'vue';
import Token from '../abis/Token.json'
import LoanShark from '../abis/LoanShark.json'

const { address } = storeToRefs(useStore())

const provider = new ethers.providers.Web3Provider(window.ethereum)

const balances = reactive({
    eth: 0,
    token: 0
})

const contractDetails = reactive({
    address: null as string | null,
    eth: 0,
    token: 0
})

const tokenDetails = reactive({
    name: null as string | null,
    symbol: null as string | null,
    address: null as string | null,
})

let token = null
let loanshark = null

onMounted(init)
watch(address, init)

async function init() {
    if (!address.value) return

    // Get loan shark contract
    loanshark = new ethers.Contract(LoanShark.address, LoanShark.abi, provider.getSigner())

    const tokenAddress = await loanshark.stablecoin()
    // Get token contract
    token = new ethers.Contract(tokenAddress, Token.abi, provider.getSigner())
    tokenDetails.address = tokenAddress
    tokenDetails.name = await token.name()
    tokenDetails.symbol = await token.symbol()

    // Get User's ETH and Token balance
    balances.eth = +formatEther(await provider.getBalance(address.value))
    balances.token = +formatEther(await token.balanceOf(address.value))

    // Get Contract's ETH and Token balance 
    contractDetails.address = LoanShark.address
    contractDetails.eth = +formatEther(await provider.getBalance(LoanShark.address))
    contractDetails.token = +formatEther(await token.balanceOf(LoanShark.address))
}

</script>

<template>
    <div>
        <Navbar />
        <div class="mx-auto w-11/12 md:w-1/2">
            <div class="mt-10 border rounded-lg p-5">
                <h1 class="flex space-x-2 items-center text-sm font-medium">
                    <Jazzicon :diameter="40" :address="address" class="mt-1" /><span>{{ address }}</span>
                </h1>
                <h1 class="font-bold mt-2">ETH Balance</h1>
                <p>{{ balances.eth }}</p>
                <h1 class="font-bold mt-2">{{ tokenDetails.name }} Balance</h1>
                <p>{{ balances.token }}</p>
            </div>
            <div class="mt-10 border rounded-lg p-5">
                <div class="flex space-x-2 items-center">
                    <Jazzicon :diameter="40" :address="contractDetails.address" class="mt-1.5" />
                    <div>
                        <h1 class="text-sm font-bold">LoanShark Contract</h1>
                        <h2 class="text-xs text-gray-500">{{ contractDetails.address }}</h2>
                    </div>
                </div>
                <h1 class="font-bold mt-2">ETH Balance</h1>
                <p>{{ contractDetails.eth }}</p>
                <h1 class="font-bold mt-2">{{ tokenDetails.name }} Balance</h1>
                <p>{{ contractDetails.token }}</p>
            </div>
            <!-- Borrow card -->
            <div class="mt-3">
                <h1 class="font-bold text-xl">Borrow</h1>
            </div>
        </div>
    </div>
</template>