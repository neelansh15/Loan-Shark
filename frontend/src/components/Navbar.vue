<script lang="ts" setup>
import { storeToRefs } from 'pinia';
import { onMounted } from 'vue';
import { ConnectWalletButton, useMetaMaskWallet } from 'vue-connect-wallet'
import { useStore } from '../store/useStore'

const store = useStore()
const wallet = useMetaMaskWallet()

const { address } = storeToRefs(store)


const connect = async () => {
    const accounts = await wallet.connect()
    if (typeof accounts === 'string') return
    store.$patch({
        address: accounts[0]
    })
}

wallet.onAccountsChanged(connect)

onMounted(async () => {
    const accounts = await wallet.getAccounts()
    const isConnected = typeof accounts != 'string' && accounts.length > 0
    if (isConnected) connect()
})

</script>

<template>
    <div class="p-5 bg-gray-100 flex justify-between items-center">
        <h1>LoanShark</h1>
        <div>
            <ConnectWalletButton :address="address || ''" @click="connect" />
        </div>
    </div>
</template>