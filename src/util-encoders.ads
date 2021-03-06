-----------------------------------------------------------------------
--  util-encoders -- Encode/Decode streams and strings from one format to another
--  Copyright (C) 2009, 2010, 2011, 2012, 2016, 2017 Stephane Carrez
--  Written by Stephane Carrez (Stephane.Carrez@gmail.com)
--
--  Licensed under the Apache License, Version 2.0 (the "License");
--  you may not use this file except in compliance with the License.
--  You may obtain a copy of the License at
--
--      http://www.apache.org/licenses/LICENSE-2.0
--
--  Unless required by applicable law or agreed to in writing, software
--  distributed under the License is distributed on an "AS IS" BASIS,
--  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
--  See the License for the specific language governing permissions and
--  limitations under the License.
-----------------------------------------------------------------------
with Ada.Streams;
with Ada.Finalization;
with Interfaces;

--  === Encoder and Decoders ===
--  The <b>Util.Encoders</b> package defines the <b>Encoder</b> and <b>Decode</b> objects
--  which provide a mechanism to transform a stream from one format into
--  another format.
--
--  ==== Simple encoding and decoding ====
--
package Util.Encoders is

   pragma Preelaborate;

   Not_Supported  : exception;
   Encoding_Error : exception;

   --  Encoder/decoder for Base64 (RFC 4648)
   BASE_64     : constant String := "base64";

   --  Encoder/decoder for Base64 (RFC 4648) using the URL alphabet
   --  (+ and / are replaced by - and _)
   BASE_64_URL : constant String := "base64url";

   --  Encoder/decoder for Base16 (RFC 4648)
   BASE_16     : constant String := "base16";
   HEX         : constant String := "hex";

   --  Encoder for SHA1 (RFC 3174)
   HASH_SHA1   : constant String := "sha1";

   --  ------------------------------
   --  Encoder context object
   --  ------------------------------
   --  The <b>Encoder</b> provides operations to encode and decode
   --  strings or stream of data from one format to another.
   --  The <b>Encoded</b> contains two <b>Transformer</b>
   --  which either <i>encodes</i> or <i>decodes</i> the stream.
   type Encoder is tagged limited private;

   --  Encodes the input string <b>Data</b> using the transformation
   --  rules provided by the <b>E</b> encoder.
   --
   --  Returns the encoded string.
   --
   --  Raises the <b>Encoding_Error</b> exception if the source string
   --  cannot be encoded.
   --  Raises the <b>Not_Supported</b> exception if the encoding is not
   --  supported.
   function Encode (E    : in Encoder;
                    Data : in String) return String;
   function Encode_Binary (E    : in Encoder;
                           Data : in Ada.Streams.Stream_Element_Array) return String;

   --  Create the encoder object for the specified encoding format.
   function Create (Name : in String) return Encoder;

   type Decoder is tagged limited private;

   --  Decodes the input string <b>Data</b> using the transformation
   --  rules provided by the <b>E</b> encoder.
   --
   --  Returns the encoded string.
   --
   --  Raises the <b>Encoding_Error</b> exception if the source string
   --  cannot be decoded.
   --  Raises the <b>Not_Supported</b> exception if the decoding is not
   --  supported.
   function Decode (E    : in Decoder;
                    Data : in String) return String;
   function Decode_Binary (E    : in Decoder;
                           Data : in String) return Ada.Streams.Stream_Element_Array;

   --  Create the decoder object for the specified encoding format.
   function Create (Name : in String) return Decoder;

   --  ------------------------------
   --  Stream Transformation interface
   --  ------------------------------
   --  The <b>Transformer</b> interface defines the operation to transform
   --  a stream from one data format to another.
   type Transformer is limited interface;
   type Transformer_Access is access all Transformer'Class;

   --  Transform the input array represented by <b>Data</b> into
   --  the output array <b>Into</b>.  The transformation made by
   --  the object can be of any nature (Hex encoding, Base64 encoding,
   --  Hex decoding, Base64 decoding, encryption, compression, ...).
   --
   --  If the transformer does not have enough room to write the result,
   --  it must return in <b>Encoded</b> the index of the last encoded
   --  position in the <b>Data</b> array.
   --
   --  The transformer returns in <b>Last</b> the last valid position
   --  in the output array <b>Into</b>.
   --
   --  The <b>Encoding_Error</b> exception is raised if the input
   --  array cannot be transformed.
   procedure Transform (E       : in out Transformer;
                        Data    : in Ada.Streams.Stream_Element_Array;
                        Into    : out Ada.Streams.Stream_Element_Array;
                        Last    : out Ada.Streams.Stream_Element_Offset;
                        Encoded : out Ada.Streams.Stream_Element_Offset) is abstract;

   --  Finish encoding the input array.
   procedure Finish (E    : in out Transformer;
                     Into : in out Ada.Streams.Stream_Element_Array;
                     Last : in out Ada.Streams.Stream_Element_Offset) is null;

   --  Transform the input string <b>Data</b> using the transformation
   --  rules provided by the <b>E</b> transformer.
   --
   --  Returns the transformed string.
   --
   --  Raises the <b>Encoding_Error</b> exception if the source string
   --  cannot be transformed
   function Transform (E    : in out Transformer'Class;
                       Data : in String) return String;

   --  Transform the input string <b>Data</b> using the transformation
   --  rules provided by the <b>E</b> transformer.
   --
   --  Returns the transformed string.
   --
   --  Raises the <b>Encoding_Error</b> exception if the source string
   --  cannot be transformed
   function Transform (E    : in out Transformer'Class;
                       Data : in Ada.Streams.Stream_Element_Array) return String;
   function Transform (E    : in out Transformer'Class;
                       Data : in Ada.Streams.Stream_Element_Array)
                       return Ada.Streams.Stream_Element_Array;

   --  Transform the input string <b>Data</b> using the transformation
   --  rules provided by the <b>E</b> transformer and return the data in
   --  the <b>Into</b> array, setting <b>Last</b> to the last index.
   --
   --  Raises the <b>Encoding_Error</b> exception if the source string
   --  cannot be transformed
   procedure Transform (E    : in out Transformer'Class;
                        Data : in String;
                        Into : out Ada.Streams.Stream_Element_Array;
                        Last : out Ada.Streams.Stream_Element_Offset);

   --  Encode the value represented by <tt>Val</tt> in the stream array <tt>Into</tt> starting
   --  at position <tt>Pos</tt> in that array.  The value is encoded using LEB128 format, 7-bits
   --  at a time until all non zero bits are written.  The <tt>Last</tt> parameter is updated
   --  to indicate the position of the last valid byte written in <tt>Into</tt>.
   procedure Encode_LEB128 (Into  : in out Ada.Streams.Stream_Element_Array;
                            Pos   : in Ada.Streams.Stream_Element_Offset;
                            Val   : in Interfaces.Unsigned_64;
                            Last  : out Ada.Streams.Stream_Element_Offset);

   --  Decode from the byte array <tt>From</tt> the value represented as LEB128 format starting
   --  at position <tt>Pos</tt> in that array.  After decoding, the <tt>Last</tt> index is updated
   --  to indicate the last position in the byte array.
   procedure Decode_LEB128 (From  : in Ada.Streams.Stream_Element_Array;
                            Pos   : in Ada.Streams.Stream_Element_Offset;
                            Val   : out Interfaces.Unsigned_64;
                            Last  : out Ada.Streams.Stream_Element_Offset);

private

   --  Transform the input data into the target string.
   procedure Convert (E    : in out Transformer'Class;
                      Data : in Ada.Streams.Stream_Element_Array;
                      Into : out String);

   type Encoder is new Ada.Finalization.Limited_Controlled with record
      Encode : Transformer_Access := null;
   end record;

   --  Delete the transformers
   overriding
   procedure Finalize (E : in out Encoder);

   type Decoder is new Ada.Finalization.Limited_Controlled with record
      Decode : Transformer_Access := null;
   end record;

   --  Delete the transformers
   overriding
   procedure Finalize (E : in out Decoder);

end Util.Encoders;
