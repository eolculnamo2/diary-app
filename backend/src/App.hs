{-# LANGUAGE DataKinds #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE OverloadedStrings #-}

module App where

import           Data.Aeson
import           GHC.Generics
import           Network.Wai
import           Network.Wai.Handler.Warp
import           Network.Wai (Middleware)
import           Network.Wai.Middleware.AddHeaders (addHeaders)
import           Network.Wai.Middleware.Cors
-- import          http-types-0.12.2:Network.HTTP.Types.Header.HeaderName
import           Servant
import           System.IO


-- import           Resources.Api

-- * api

type ItemApi =
  "item" :> Get '[JSON] [Item] :<|>
  "item" :> Capture "itemId" Integer :> Get '[JSON] Item :<|>
  "login" :> ReqBody '[JSON] User :> Post '[JSON] User :<|>
  "get-entries" :> Get '[JSON] [Entry]

itemApi :: Proxy ItemApi
itemApi = Proxy

-- NOTE: was getting an error about bytestring type for corsRequestHeaders and fixed by adding OverloadedStrings
-- https://stackoverflow.com/questions/41399055/haskell-yesod-cors-problems-with-browsers-options-requests-when-doing-post-req/56256513#56256513
allowCors :: Middleware
allowCors = cors (const $ Just appCorsResourcePolicy)

appCorsResourcePolicy :: CorsResourcePolicy
appCorsResourcePolicy = CorsResourcePolicy {
    corsOrigins        = Nothing
  , corsMethods        = ["OPTIONS", "GET", "PUT", "POST"]
  , corsRequestHeaders = ["Authorization", "Content-Type"]
  , corsExposedHeaders = Nothing
  , corsMaxAge         = Nothing
  , corsVaryOrigin     = False
  , corsRequireOrigin  = False
  , corsIgnoreFailures = False
}

-- * app

run :: IO ()
run = do
  let port = 3000
      settings =
        setPort port $
        setBeforeMainLoop (hPutStrLn stderr ("listening on port " ++ show port)) $
        defaultSettings
  runSettings settings =<< mkApp

mkApp :: IO Application
mkApp = return $ allowCors $ serve itemApi server

server :: Server ItemApi
server =
  getItems :<|>
  getItemById :<|>
  handleLogin :<|>
  getEntries

getItems :: Handler [Item]
getItems = return [exampleItem]

getItemById :: Integer -> Handler Item
getItemById = \ case
  0 -> return exampleItem
  _ -> throwError err404

exampleItem :: Item
exampleItem = Item 0 "example item"

validateUser :: String -> Bool
validateUser password
  | password == "123" = True
  | otherwise = False

handleLogin :: User -> (Handler User)
handleLogin user = if ((validateUser $ password user) == True) then return user else throwError err403

exampleUser :: User
exampleUser = User "rob" "123"

getEntries :: Handler [Entry]
getEntries = return [Entry "Rob" "I had a great day today" 0, Entry "Rob" "I went for a walk to the park" 2]

-- * item

data Item
  = Item {
    itemId :: Integer,
    itemText :: String
  }
  deriving (Eq, Show, Generic)

data User = User {
    username :: String,
    password :: String
  }
  deriving (Eq, Show, Generic)

data Entry = Entry {
  author :: String,
  content :: String,
  likes :: Int
} deriving (Eq, Show, Generic)

instance ToJSON Item
instance FromJSON Item

instance ToJSON User
instance FromJSON User

instance ToJSON Entry
instance FromJSON Entry

data a + b = Foo a b

type X = Int + Bool
