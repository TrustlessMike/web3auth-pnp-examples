import type { IProvider } from "@web3auth/base";
import { getHttpEndpoint } from "@orbs-network/ton-access";
import TonWeb from "tonweb";

const rpc = await getHttpEndpoint({
    network: "testnet",
    protocol: "json-rpc",
}); 

export default class TonRPC {
    private provider: IProvider;
    private tonweb: TonWeb;

    constructor(provider: IProvider) {
        this.provider = provider;
        this.tonweb = new TonWeb(new TonWeb.HttpProvider(rpc));
    }

    async getAccounts(): Promise<string> {
        try {
            const privateKey = await this.getPrivateKey();
            const keyPair = this.getKeyPairFromPrivateKey(privateKey);
            const WalletClass = this.tonweb.wallet.all['v3R2'];
            const wallet = new WalletClass(this.tonweb.provider, {
                publicKey: keyPair.publicKey
            });
            const address = await wallet.getAddress();
            return address.toString(true, true, true);
        } catch (error) {
            console.error("Error getting accounts:", error);
            return "";
        }
    }

     getChainId(): string {
        return "testnet"; 
    }

    async getBalance(): Promise<string> {
        try {
            const address = await this.getAccounts();
            const balance = await this.tonweb.getBalance(address);
            return TonWeb.utils.fromNano(balance);
        } catch (error) {
            console.error("Error getting balance:", error);
            return "0";
        }
    }

    async sendTransaction(): Promise<any> {
        try {
            const privateKey = await this.getPrivateKey();
            const keyPair = this.getKeyPairFromPrivateKey(privateKey);
            
            const WalletClass = this.tonweb.wallet.all["v3R2"];
            const wallet = new WalletClass(this.tonweb.provider, { publicKey: keyPair.publicKey });
    
            const address = await wallet.getAddress();
            console.log("Wallet address:", address.toString(true, true, true));
    
            const balance = await this.tonweb.getBalance(address);
            console.log("Wallet balance:", TonWeb.utils.fromNano(balance.toString()));
    
            let seqno = await wallet.methods.seqno().call() ?? 0;
            console.log("Using seqno:", seqno);
    
            const transfer = wallet.methods.transfer({
                secretKey: keyPair.secretKey,
                toAddress: '0QCeWpE40bPUiuj-8ZfZd2VzMOxCMUuQFa_VKmdD8ssy5ukA',
                amount: TonWeb.utils.toNano('0.004'),
                seqno: seqno,
                payload: 'Hello, TON!',
                sendMode: 3,
            });
    
            console.log("Sending transaction...");
            const result = await transfer.send();
            
            console.log(result);
            // Return the full result for display in uiConsole
            return result;
        } catch (error) {
            console.error("Error sending transaction:", error);
            return { error: error instanceof Error ? error.message : String(error) };
        }
    }

    public getKeyPairFromPrivateKey(privateKey: string): { publicKey: Uint8Array; secretKey: Uint8Array } {
        // Convert the hex string to a Uint8Array
        const privateKeyBytes = new Uint8Array(privateKey.match(/.{1,2}/g)!.map(byte => parseInt(byte, 16)));

        // Ensure the private key is 32 bytes (256 bits)
        if (privateKeyBytes.length !== 32) {
            // If it's shorter, pad it. If it's longer, truncate it.
            const adjustedPrivateKey = new Uint8Array(32);
            adjustedPrivateKey.set(privateKeyBytes.slice(0, 32));
            return TonWeb.utils.nacl.sign.keyPair.fromSeed(adjustedPrivateKey);
        }

        // If it's already 32 bytes, use it directly
        return TonWeb.utils.nacl.sign.keyPair.fromSeed(privateKeyBytes);
    }

    async getPrivateKey(): Promise<string> {
        try {
            return await this.provider.request({
                method: "private_key",
            });
        } catch (error) {
            console.error("Error getting private key:", error);
            throw error;
        }
    }

}