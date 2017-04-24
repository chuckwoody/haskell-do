{-
 - Copyright (c) 2017 The Agile Monkeys S.L. <hackers@theam.io>
 -
 - Licensed under the Apache License, Version 2.0 (the "License");
 - you may not use this file except in compliance with the License.
 - You may obtain a copy of the License at
 -
 -     http://www.apache.org/licenses/LICENSE-2.0
 -
 - Unless required by applicable law or agreed to in writing, software
 - distributed under the License is distributed on an "AS IS" BASIS,
 - WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 - See the License for the specific language governing permissions and
 - limitations under the License.
 -}
module HaskellDo.GUI.External.SimpleMDE.JavascriptInternals
  ( simpleMDE
  , initializeSimpleMDE
  , setRendered
  )
where

import BasicPrelude hiding (id, div, empty)
import GHCJS.Types
import Data.JSString hiding (concat)

import GHCJS.HPlay.View hiding (map, option,input)

import HaskellDo.GUI.External.SimpleMDE.Common

foreign import javascript unsafe "simpleMDE.value()"
    js_getMDEContent :: IO JSString

initializeSimpleMDE :: IO ()
initializeSimpleMDE =
    addHeader $ do
        link ! atr (fromString "rel") (fromString "stylesheet")
             ! href (fromString "https://cdn.jsdelivr.net/simplemde/latest/simplemde.min.css")
        script (pack "var simpleMDE; var renderedCode;" :: JSString)
        script ! src (fromString "https://cdn.jsdelivr.net/simplemde/latest/simplemde.min.js")
               $ noHtml
        script (fromString initScript :: JSString)
  where
    initScript =
        concat  [ "function initMDE() {"
                ,    "if (typeof SimpleMDE !== 'undefined') {"
                ,        "simpleMDE=new SimpleMDE({"
                ,           "tabSize: 2, status: false,"
                ,           "previewRender: function(x){return renderedCode;}"
                ,        "});"
                ,    "} else {"
                ,        "window.setTimeout(initMDE, 10);"
                ,    "}"
                , "};"
                , "initMDE()"
                ]

simpleMDE :: Widget String
simpleMDE = do
    _ <- textArea "" `fire` OnKeyUp `fire` OnClick
    content <- liftIO js_getMDEContent
    return $ unpack content

foreign import javascript unsafe "renderedCode = $1;"
    js_setRendered :: JSString -> IO ()

setRendered :: String -> IO ()
setRendered = js_setRendered . pack