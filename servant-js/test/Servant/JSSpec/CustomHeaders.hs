{-# LANGUAGE DataKinds           #-}
{-# LANGUAGE FlexibleInstances   #-}
{-# LANGUAGE KindSignatures      #-}
{-# LANGUAGE PolyKinds           #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeFamilies        #-}
{-# LANGUAGE TypeOperators       #-}
{-# LANGUAGE OverloadedStrings   #-}

module Servant.JSSpec.CustomHeaders where

import           Control.Lens
import           Data.Monoid
import           Data.Proxy
import           Data.Text (pack)
import           GHC.TypeLits
import           Servant.JS.Internal

-- | This is a hypothetical combinator that fetches an Authorization header.
-- The symbol in the header denotes what kind of authentication we are
-- using -- Basic, Digest, whatever.
data Authorization (sym :: Symbol) a

instance (KnownSymbol sym, HasForeign sublayout)
    => HasForeign (Authorization sym a :> sublayout) where
    type Foreign (Authorization sym a :> sublayout) = Foreign sublayout

    foreignFor Proxy req = foreignFor (Proxy :: Proxy sublayout) $
        req & reqHeaders <>~ [ ReplaceHeaderArg "Authorization" $
                               tokenType (pack . symbolVal $ (Proxy :: Proxy sym)) ]
      where
        tokenType t = t <> " {Authorization}"

-- | This is a combinator that fetches an X-MyLovelyHorse header.
data MyLovelyHorse a

instance (HasForeign sublayout)
    => HasForeign (MyLovelyHorse a :> sublayout) where
    type Foreign (MyLovelyHorse a :> sublayout) = Foreign sublayout

    foreignFor Proxy req = foreignFor (Proxy :: Proxy sublayout) $
        req & reqHeaders <>~ [ ReplaceHeaderArg "X-MyLovelyHorse" tpl ]
      where
        tpl = "I am good friends with {X-MyLovelyHorse}"

-- | This is a combinator that fetches an X-WhatsForDinner header.
data WhatsForDinner a

instance (HasForeign sublayout)
    => HasForeign (WhatsForDinner a :> sublayout) where
    type Foreign (WhatsForDinner a :> sublayout) = Foreign sublayout

    foreignFor Proxy req = foreignFor (Proxy :: Proxy sublayout) $
        req & reqHeaders <>~ [ ReplaceHeaderArg "X-WhatsForDinner" tpl ]
      where
        tpl = "I would like {X-WhatsForDinner} with a cherry on top."
