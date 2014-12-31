{-# LANGUAGE DeriveDataTypeable   #-}
{-# LANGUAGE FlexibleInstances    #-}
{-# LANGUAGE GADTs                #-}
{-# LANGUAGE OverloadedStrings    #-}
{-# LANGUAGE RankNTypes           #-}
{-# LANGUAGE UndecidableInstances #-}

module Netsuite.Types.Data.Core (
    NsType (..),
    NsSubtype (..),

    IsNsType,
    toNsType,

    IsNsSubtype,
    toNsSubtype,

    typeFields,
    getTypeFromSubtype
) where

import Data.Aeson
import Data.Data
import Data.Text
import Data.Typeable ()

import Netsuite.Types.Data.TypeFamily
import Netsuite.Types.Fields

--------------------------------------------------------------------------------
-- | Netsuite record type
newtype NsType = NsType Text deriving (Data, Typeable)

instance Show NsType where
    show (NsType t) = unpack t

instance ToJSON NsType where
    toJSON = toJSON . show

instance NsTypeFamily NsType where
    toTypeIdentList (NsType t) = [t]
    toDefaultFields = nsTypeFields . toTypeIdentList

-- | Turn simpler types into NsType
class IsNsType a where
    toNsType :: a -> NsType

instance IsNsType Text where
    toNsType = NsType

instance IsNsType [Text] where
    toNsType (a:_) = NsType a
    toNsType _     = error "Not enough arguments in list for NsType"

--------------------------------------------------------------------------------
-- | Netsuite record subtype
data NsSubtype = NsSubtype NsType Text deriving (Data, Typeable)

instance Show NsSubtype where
    show (NsSubtype t s) = show t ++ "." ++ unpack s

instance ToJSON NsSubtype where
    toJSON (NsSubtype _ s) = toJSON . unpack $ s

instance NsTypeFamily NsSubtype where
    toTypeIdentList (NsSubtype t s) = toTypeIdentList t ++ [s]
    toDefaultFields = nsSubtypeFields . toTypeIdentList

getTypeFromSubtype :: NsSubtype -> NsType
getTypeFromSubtype (NsSubtype t _) = t

-- | Turn simpler types into NsSubtype
class IsNsSubtype a where
    toNsSubtype :: a -> NsSubtype

instance (IsNsType a) => IsNsSubtype (a, Text) where
    toNsSubtype (a, b) = NsSubtype (toNsType a) b

instance IsNsSubtype [Text] where
    toNsSubtype (a:b:_) = NsSubtype (NsType a) b
    toNsSubtype _       = error "Not enough arguments in list for NsSubtype"
