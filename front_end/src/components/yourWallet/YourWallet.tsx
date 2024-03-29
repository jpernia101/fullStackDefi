import { Token } from "../Main"
import {Box, Tab } from "@material-ui/core"
import {TabContext, TabList, TabPanel} from "@material-ui/lab"
import { useState } from "react"
interface YourWalletProps {
    supportedTokens: Array<Token>
}
export const YourWallet =  ({supportedTokens}: YourWalletProps) => {
    const [selectedTokenIndex, setselectedTokenIndex] = useState<number>(0)
    const handleChange = (event: React.ChangeEvent<{}>, newValue:string) => {
        setselectedTokenIndex(parseInt(newValue))
    }
    
    return (
        <Box>
            <h1> Your Wallet</h1>
            <Box>
                <TabContext value={selectedTokenIndex.toString()}>
                    <TabList aria-label="stake form tabs" onChange={handleChange}>
                        {supportedTokens.map( (token, index) => {
                            return(
                                <Tab label={token.name} value={index.toString()} key={index}/>
                            )
                        })
                        }
                    </TabList>
                </TabContext>
            </Box>
        </Box>
    )
}