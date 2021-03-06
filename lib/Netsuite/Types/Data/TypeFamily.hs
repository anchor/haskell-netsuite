module Netsuite.Types.Data.TypeFamily (
    NsTypeFamily,
    toTypeIdentList,
    toDefaultFields,
    typeFields
) where

import Data.Map
import Data.Maybe
import Netsuite.Restlet.Configuration
import Netsuite.Types.Fields.Core
import Prelude hiding (lookup)

--------------------------------------------------------------------------------
-- | Type family class
class NsTypeFamily a where
    toTypeIdentList :: a -> [String]
    toDefaultFields :: a -> [String]

--------------------------------------------------------------------------------
-- | Get list of NsFields for a particular NsType or NsSubtype
typeFields :: (NsTypeFamily a) => NsRestletConfig -> a -> NsFields
typeFields cfg t = NsFields $ toDefaultFields t ++ getCfgFields cfg t

-- | Get type fields plus extra fields from configuration
getCfgFields :: (NsTypeFamily a) => NsRestletConfig -> a -> [String]
getCfgFields cfg t = maybe [] cfgFields $ restletCustomFields cfg
  where
    cfgFields = fromMaybe [] . lookup (toTypeIdentList t)
