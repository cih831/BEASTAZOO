// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./token/ERC721/ERC721.sol";
/**
 * PJT Ⅰ - 과제 2) NFT Creator 구현
 * 상태 변수나 함수의 시그니처는 구현에 따라 변경할 수 있습니다.
 */
contract JAV_NFT is ERC721 {
    constructor() ERC721("javjongNFT","JNFT"){
    }
    // import
    

    // 저장된 데이터들
    struct javsDetail {
        uint[3] gene;     // [머리,귀,하관]
        uint[4] accessory; // [악세1,악세2,악세3,악세4]
        uint256 create_at;
    }

    uint256 private _tokenIds;
    mapping(uint256 => string) tokenURIs;
    mapping(uint256 => javsDetail) javsData;
    event createNFT (uint256 indexed _tokenId, address indexed _owner);

    // 각종 조회 함수들
    // 현재까지 생성된 NFT 수 ,지워버린 토큰까지 포함
    function current() public view returns (uint256) {
        return _tokenIds;
    }
    // 토큰안에 들어있는 URL 조회
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        return tokenURIs[tokenId];
    }
    // 유전정보 조회
    function getJavsGene(uint256 tokenId) public view returns (uint[3] memory) {
        // 여기서 암호화 하면되긴 하는데, 단순 수학 계산을 이용하여 암호화 해야 할듯?
        return javsData[tokenId].gene;
    }

    function getJavsAccessory(uint256 tokenId) public view returns (uint[4] memory) {
        return javsData[tokenId].accessory;
    }

    function getJavsCreate_at(uint256 tokenId) public view returns (uint256) {
        return javsData[tokenId].create_at;
    }

    // 뽑기,조합 관련 함수들
    
    // NFT 생성
    function create(address to, string memory _tokenURI, uint[3] memory _gene, uint[4] memory _accessory) internal returns (uint256) {
        uint256 tokenId = current() + 1;
        tokenURIs[tokenId] = _tokenURI;
        _tokenIds = tokenId;
        _mint(to, tokenId);
        // 데이터 조회를 위해 추가
        javsData[tokenId].gene =  _gene;
        javsData[tokenId].accessory = _accessory;
        javsData[tokenId].create_at = block.timestamp;
        emit createNFT(tokenId, to);

        return tokenId;
    }

    // 알고리즘
    // 파츠 한개씩 만 반환
    // function randomGene() pure internal returns (uint80){
    //     // 랜덤
    //     return 1111111111111111111111;
    // }
    // 파츠 한개씩 만 반환
    // function makeGene(uint _gene1, uint _gene2) pure internal returns (uint80){
    //     // 특별한 알고리즘 필요
    //     uint temp = _gene1 + _gene2;
    //     return temp;
    // }
    // 부위마다 랜덤 범위가 달라서 gene과 다르게 한번에 값이 나오게 했음
    // function randomAccessory() pure internal returns (uint8[4] memory){
    //     // 랜덤
    //     uint8[4] memory temp; 
    //     return temp;
    // }
    // 뽑기
    function pickup(string memory _tokenURI) public returns (uint256) {
        // 돈 관련 체크 필요 혹은 public을 external로 변경하여 다른 계약에서 호출, 호출시 this.pickup()형태
        uint[3] memory _gene = [gacha(),gacha(),gacha()];
        uint[4] memory _accessory = [getAcce1(),getAcce2(),getAcce3(),getAcce4()];
        uint256 value = create(msg.sender,_tokenURI,_gene,_accessory);
        return value;
    }

    // 조합
    function fusionJavs(string memory _tokenURI, uint256 NFTid1, uint256 NFTid2) public returns (uint256){
        // 돈 관련 체크 필요 혹은 public을 external로 변경
        // burn된 token의 경우 ERC721에서 ownerOf 하면서 처리해줌
        require(msg.sender == ownerOf(NFTid1), "you are not NFT owner");
        require(msg.sender == ownerOf(NFTid2), "you are not NFT owner");
        uint[3] memory NFT1_gene = javsData[NFTid1].gene;
        uint[3] memory NFT2_gene = javsData[NFTid2].gene;
        uint[3] memory new_gene;
        for (uint i = 0; i < 3; i++) {
            new_gene[i] = fusion(NFT1_gene[i],NFT2_gene[i]);
        }

        uint[4] memory _accessory = [getAcce1(),getAcce2(),getAcce3(),getAcce4()];
        _burn(NFTid1);
        _burn(NFTid2);
        uint256 value = create(msg.sender,_tokenURI,new_gene,_accessory);
        return value;
    }
    
    function _burn(uint256 tokenId) internal override {
        super._burn(tokenId);
        delete javsData[tokenId];
        delete tokenURIs[tokenId];
    }

    // 유전 알고리즘
    uint[7] weight = [1, 1, 1, 1, 6, 6, 24];
    uint[3] fusionWeight = [2, 2, 1];
    uint[3] colorWeight = [1, 1, 1];
    uint[3] gachaWeight = [1, 1, 1];
    uint temp;

    function gacha() public returns (uint) {

        uint random = uint(keccak256(abi.encodePacked(block.timestamp + temp))) % 100;
        uint random2 = uint(keccak256(abi.encodePacked(random))) % 100;
        uint random3 = uint(keccak256(abi.encodePacked(random2))) % 100;
        uint random4 = uint(keccak256(abi.encodePacked(random3))) % 100;
        uint random5 = uint(keccak256(abi.encodePacked(random4))) % 100;

        uint color = _colorPicker(random);
        uint self = _gacha(random2);
        uint mother = _gacha(random3);
        uint fatherMother = _gacha(random4);
        uint motherMother = _gacha(random5);
        
        uint myGene = color * (16 ** 21)
        + self * (16 ** 18)
        + self * (16 ** 15)
        + mother * (16 ** 12)
        + self * (16 ** 9)
        + fatherMother * (16 ** 6)
        + mother * (16 ** 3)
        + motherMother * (16 ** 0);

        temp ++;
        
        return myGene;
    }

    function fusion(uint _geneX, uint _geneY) public view returns (uint) {
        uint[7] memory arrayX;
        uint[7] memory arrayY;
        uint random = uint(keccak256(abi.encodePacked(block.timestamp))) % 100;
        uint random2 = uint(keccak256(abi.encodePacked(random))) % 100;
        uint random3 = uint(keccak256(abi.encodePacked(random2))) % 100;
        uint random4 = uint(keccak256(abi.encodePacked(random3))) % 100;

        for (uint i = 1; i < weight.length + 1; i++) {
            arrayX[i-1] = _geneX % (16 ** ((i * 3) - (i - 1) * 3));
            arrayY[i-1] = _geneY % (16 ** ((i * 3) - (i - 1) * 3));
        }

        uint winX = _winner(arrayX, random);
        uint winY = _winner(arrayY, random2);

        uint winZ = _fusion(winX, winY, random3);
        uint color = _colorPicker(random4);
        
        uint childTemp = color * (16 ** 21)
        + winZ * (16 ** 18)
        + arrayX[6] * (16 ** 15)
        + arrayY[6] * (16 ** 12);

        uint child = childTemp
        + arrayX[5] * (16 ** 9)
        + arrayX[4] * (16 ** 6)
        + arrayY[5] * (16 ** 3)
        + arrayY[4] * (16 ** 0);
        
        return child;
    }

    function getAcce1() public view returns (uint) {
      uint random = uint(keccak256(abi.encodePacked(block.timestamp + 1001))) % 100;

      for (uint i = 1; i < 17; i++) {
          if (random < i * 100 / 16) {
            uint acce = 16 ** 2 + i;
            return acce;
          }
      }
      return 0;
    }

    function getAcce2() public view returns (uint) {
      uint random = uint(keccak256(abi.encodePacked(block.timestamp + 1002))) % 100;

      for (uint i = 1; i < 13; i++) {
          if (random < i * 100 / 12) {
            uint acce = 2 * (16 ** 2) + i;
            return acce;
          }
      }
      return 0;
    }

    function getAcce3() public view returns (uint) {
      uint random = uint(keccak256(abi.encodePacked(block.timestamp + 1003))) % 100;

      for (uint i = 1; i < 14; i++) {
          if (random < i * 100 / 13) {
            uint acce = 3 * (16 ** 2) + i;
            return acce;
          }
      }
      return 0;
    }

    function getAcce4() public view returns (uint) {
      uint random = uint(keccak256(abi.encodePacked(block.timestamp + 1004))) % 100;

      for (uint i = 1; i < 13; i++) {
          if (random < i * 100 / 12) {
            uint acce = 4 * (16 ** 2) + i;
            return acce;
          }
      }
      return 0;
    }

    function _winner(uint[7] memory _array, uint _random) private view returns (uint) {
        uint weightSum;

        for (uint i = 0; i < 7; i++) {
            weightSum += weight[i];

            if (_random < weightSum * 100 / 40) {
                return _array[i];
            }
        }
        return 0;
    }

    function _fusion(uint x, uint y, uint _random) private view returns (uint) {
        if (x == 0x001) {
            if (y == 0x001) {
                uint[3] memory fusionArray = [x, y, y];
                uint res = _fusionWinner(fusionArray, _random);
                return res;
            } else if (y == 0x002) {
                uint[3] memory fusionArray = [x, y, 0x004];
                uint res = _fusionWinner(fusionArray, _random);
                return res;
            } else if (y == 0x003) {
                uint[3] memory fusionArray = [x, y, 0x005];
                uint res = _fusionWinner(fusionArray, _random);
                return res;
            } else {
                uint[3] memory fusionArray = [y, y, x];
                uint res = _fusionWinner(fusionArray, _random);
                return res;
            }
        } else if (x == 0x002) {
            if (y == 0x001) {
                uint[3] memory fusionArray = [x, y, 0x004];
                uint res = _fusionWinner(fusionArray, _random);
                return res;
            } else if (y == 0x002) {
                uint[3] memory fusionArray = [x, y, y];
                uint res = _fusionWinner(fusionArray, _random);
                return res;
            } else if (y == 0x003) {
                uint[3] memory fusionArray = [x, y, 0x006];
                uint res = _fusionWinner(fusionArray, _random);
                return res;
            } else {
                uint[3] memory fusionArray = [y, y, x];
                uint res = _fusionWinner(fusionArray, _random);
                return res;
            }
        } else if (x == 0x003) {
            if (y == 0x001) {
                uint[3] memory fusionArray = [x, y, 0x005];
                uint res = _fusionWinner(fusionArray, _random);
                return res;
            } else if (y == 0x002) {
                uint[3] memory fusionArray = [x, y, 0x006];
                uint res = _fusionWinner(fusionArray, _random);
                return res;
            } else if (y == 0x003) {
                uint[3] memory fusionArray = [x, y, y];
                uint res = _fusionWinner(fusionArray, _random);
                return res;
            } else {
                uint[3] memory fusionArray = [y, y, x];
                uint res = _fusionWinner(fusionArray, _random);
                return res;
            }
        } else if (x == 0x004) {
            if (y == 0x001 || y == 0x002 || y == 0x003) {
                uint[3] memory fusionArray = [x, x, y];
                uint res = _fusionWinner(fusionArray, _random);
                return res;
            } else if (y == 0x004) {
                uint[3] memory fusionArray = [x, y, y];
                uint res = _fusionWinner(fusionArray, _random);
                return res;
            } else if (y == 0x005) {
                uint[3] memory fusionArray = [x, y, 0x007];
                uint res = _fusionWinner(fusionArray, _random);
                return res;
            } else if (y == 0x006) {
                uint[3] memory fusionArray = [x, y, 0x008];
                uint res = _fusionWinner(fusionArray, _random);
                return res;
            } else {
                uint[3] memory fusionArray = [y, y, x];
                uint res = _fusionWinner(fusionArray, _random);
                return res;
            }
        } else if (x == 0x005) {
            if (y == 0x001 || y == 0x002 || y == 0x003) {
                uint[3] memory fusionArray = [x, x, y];
                uint res = _fusionWinner(fusionArray, _random);
                return res;
            } else if (y == 0x004) {
                uint[3] memory fusionArray = [x, y, 0x007];
                uint res = _fusionWinner(fusionArray, _random);
                return res;
            } else if (y == 0x005) {
                uint[3] memory fusionArray = [x, y, y];
                uint res = _fusionWinner(fusionArray, _random);
                return res;
            } else if (y == 0x006) {
                uint[3] memory fusionArray = [x, y, 0x009];
                uint res = _fusionWinner(fusionArray, _random);
                return res;
            } else {
                uint[3] memory fusionArray = [y, y, x];
                uint res = _fusionWinner(fusionArray, _random);
                return res;
            }
        } else if (x == 0x006) {
            if (y == 0x001 || y == 0x002 || y == 0x003) {
                uint[3] memory fusionArray = [x, x, y];
                uint res = _fusionWinner(fusionArray, _random);
                return res;
            } else if (y == 0x004) {
                uint[3] memory fusionArray = [x, y, 0x008];
                uint res = _fusionWinner(fusionArray, _random);
                return res;
            } else if (y == 0x005) {
                uint[3] memory fusionArray = [x, y, 0x009];
                uint res = _fusionWinner(fusionArray, _random);
                return res;
            } else if (y == 0x006) {
                uint[3] memory fusionArray = [x, y, y];
                uint res = _fusionWinner(fusionArray, _random);
                return res;
            } else {
                uint[3] memory fusionArray = [y, y, x];
                uint res = _fusionWinner(fusionArray, _random);
                return res;
            }
        } else {
            uint[3] memory fusionArray = [y, y, x];
            uint res = _fusionWinner(fusionArray, _random);
            return res;
        }
    }

    function _fusionWinner(uint[3] memory _array, uint _random) private view returns (uint) {
        uint weightSum;

        for (uint i = 0; i < 3; i++) {
            weightSum += fusionWeight[i];

            if (_random < weightSum * 100 / 5) {
                return _array[i];
            }
        }
        return 0;
    }

    function _colorPicker(uint _random) private view returns (uint) {
        uint weightSum;

        for (uint i = 0; i < 3; i++) {
            weightSum += colorWeight[i];

            if (_random < weightSum * 100 / 3) {
                return i + 1;
            }
        }
        return 0;
    }

    function _gacha(uint _random) private view returns (uint) {
        uint weightSum;

        for (uint i = 0; i < 3; i++) {
            weightSum += gachaWeight[i];

            if (_random < weightSum * 100 / 3) {
                return i + 1;
            }
        }
        return 0;
    }
}
