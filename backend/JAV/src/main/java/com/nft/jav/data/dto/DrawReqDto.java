package com.nft.jav.data.dto;

import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.ToString;

@Data
@NoArgsConstructor
@ToString
public class DrawReqDto {
    private long user_id;
    private String nft_address;
    private String jav_code;

    @Builder
    public DrawReqDto(long user_id, String nft_address, String jav_code) {
        this.user_id = user_id;
        this.nft_address = nft_address;
        this.jav_code = jav_code;
    }
}
