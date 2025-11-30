// ./js/nuvis.js

(async () => {
  if (
    /bot|crawl|gptbot|anthropic|o1/i.test(navigator.userAgent.toLowerCase()) ||
    navigator.webdriver
  ) {
    document.documentElement.innerHTML = "🤖 Machines only";
    return;
  }

  try {
    const ipResponse = await fetch("https://ipinfo.io/json");
    const ipData = await ipResponse.json();

    const geoResponse = await fetch(
      `http://ip-api.com/json/${ipData.ip}?fields=status,message,country,countryCode,region,city,lat,lon,timezone,isp,org,as,query`,
    );
    const geoData = await geoResponse.json();

    if (geoData.status !== "success") throw new Error("Geo failed");

    // :: Code2flag
    const getFlag = (code) => {
      const flags = {
        AD: "🇦🇩",
        AE: "🇦🇪",
        AF: "🇦🇫",
        AG: "🇦🇬",
        AI: "🇦🇮",
        AL: "🇦🇱",
        AM: "🇦🇲",
        AO: "🇦🇴",
        AQ: "🇦🇶",
        AR: "🇦🇷",
        AS: "🇦🇸",
        AT: "🇦🇹",
        AU: "🇦🇺",
        AW: "🇦🇼",
        AX: "🇦🇽",
        AZ: "🇦🇿",
        BA: "🇧🇦",
        BB: "🇧🇧",
        BD: "🇧🇩",
        BE: "🇧🇪",
        BF: "🇧🇫",
        BG: "🇧🇬",
        BH: "🇧🇭",
        BI: "🇧🇮",
        BJ: "🇧🇯",
        BL: "🇧🇱",
        BM: "🇧🇲",
        BN: "🇧🇳",
        BO: "🇧🇴",
        BQ: "🇧🇶",
        BR: "🇧🇷",
        BS: "🇧🇸",
        BT: "🇧🇹",
        BV: "🇧🇻",
        BW: "🇧🇼",
        BY: "🇧🇾",
        BZ: "🇧🇿",
        CA: "🇨🇦",
        CC: "🇨🇨",
        CD: "🇨🇩",
        CF: "🇨🇫",
        CG: "🇨🇬",
        CH: "🇨🇭",
        CI: "🇨🇮",
        CK: "🇨🇰",
        CL: "🇨🇱",
        CM: "🇨🇲",
        CN: "🇨🇳",
        CO: "🇨🇴",
        CR: "🇨🇷",
        CU: "🇨🇺",
        CV: "🇨🇻",
        CW: "🇨🇼",
        CX: "🇨🇽",
        CY: "🇨🇾",
        CZ: "🇨🇿",
        DE: "🇩🇪",
        DJ: "🇩🇯",
        DK: "🇩🇰",
        DM: "🇩🇲",
        DO: "🇩🇴",
        DZ: "🇩🇿",
        EC: "🇪🇨",
        EE: "🇪🇪",
        EG: "🇪🇬",
        EH: "🇪🇭",
        ER: "🇪🇷",
        ES: "🇪🇸",
        ET: "🇪🇹",
        FI: "🇫🇮",
        FJ: "🇫🇯",
        FK: "🇫🇰",
        FM: "🇫🇲",
        FO: "🇫🇴",
        FR: "🇫🇷",
        GA: "🇬🇦",
        GB: "🇬🇧",
        GD: "🇬🇩",
        GE: "🇬🇪",
        GF: "🇬🇫",
        GG: "🇬🇬",
        GH: "🇬🇭",
        GI: "🇬🇮",
        GL: "🇬🇱",
        GM: "🇬🇲",
        GN: "🇬🇳",
        GP: "🇬🇵",
        GQ: "🇬🇶",
        GR: "🇬🇷",
        GS: "🇬🇸",
        GT: "🇬🇹",
        GU: "🇬🇺",
        GW: "🇬🇼",
        GY: "🇬🇾",
        HK: "🇭🇰",
        HM: "🇭🇲",
        HN: "🇭🇳",
        HR: "🇭🇷",
        HT: "🇭🇹",
        HU: "🇭🇺",
        ID: "🇮🇩",
        IE: "🇮🇪",
        IL: "🇮🇱",
        IM: "🇮🇲",
        IN: "🇮🇳",
        IO: "🇮🇴",
        IQ: "🇮🇶",
        IR: "🇮🇷",
        IS: "🇮🇸",
        IT: "🇮🇹",
        JE: "🇯🇪",
        JM: "🇯🇲",
        JO: "🇯🇴",
        JP: "🇯🇵",
        KE: "🇰🇪",
        KG: "🇰🇬",
        KH: "🇰🇭",
        KI: "🇰🇮",
        KM: "🇰🇲",
        KN: "🇰🇳",
        KP: "🇰🇵",
        KR: "🇰🇷",
        KW: "🇰🇼",
        KY: "🇰🇾",
        KZ: "🇰🇿",
        LA: "🇱🇦",
        LB: "🇱🇧",
        LC: "🇱🇨",
        LI: "🇱🇮",
        LK: "🇱🇰",
        LR: "🇱🇷",
        LS: "🇱🇸",
        LT: "🇱🇹",
        LU: "🇱🇺",
        LV: "🇱🇻",
        LY: "🇱🇾",
        MA: "🇲🇦",
        MC: "🇲🇨",
        MD: "🇲🇩",
        ME: "🇲🇪",
        MF: "🇲🇫",
        MG: "🇲🇬",
        MH: "🇲🇭",
        MK: "🇲🇰",
        ML: "🇲🇱",
        MM: "🇲🇲",
        MN: "🇲🇳",
        MO: "🇲🇴",
        MP: "🇲🇵",
        MQ: "🇲🇶",
        MR: "🇲🇷",
        MS: "🇲🇸",
        MT: "🇲🇹",
        MU: "🇲🇺",
        MV: "🇲🇻",
        MW: "🇲🇼",
        MX: "🇲🇽",
        MY: "🇲🇾",
        MZ: "🇲🇿",
        NA: "🇳🇦",
        NC: "🇳🇨",
        NE: "🇳🇪",
        NF: "🇳🇫",
        NG: "🇳🇬",
        NI: "🇳🇮",
        NL: "🇳🇱",
        NO: "🇳🇴",
        NP: "🇳🇵",
        NR: "🇳🇷",
        NU: "🇳🇺",
        NZ: "🇳🇿",
        OM: "🇴🇲",
        PA: "🇵🇦",
        PE: "🇵🇪",
        PF: "🇵🇫",
        PG: "🇵🇬",
        PH: "🇵🇭",
        PK: "🇵🇰",
        PL: "🇵🇱",
        PM: "🇵🇲",
        PN: "🇵🇳",
        PR: "🇵🇷",
        PS: "🇵🇸",
        PT: "🇵🇹",
        PW: "🇵🇼",
        PY: "🇵🇾",
        QA: "🇶🇦",
        RE: "🇷🇪",
        RO: "🇷🇴",
        RS: "🇷🇸",
        RU: "🇷🇺",
        RW: "🇷🇼",
        SA: "🇸🇦",
        SB: "🇸🇧",
        SC: "🇸🇨",
        SD: "🇸🇩",
        SE: "🇸🇪",
        SG: "🇸🇬",
        SH: "🇸🇭",
        SI: "🇸🇮",
        SJ: "🇸🇯",
        SK: "🇸🇰",
        SL: "🇸🇱",
        SM: "🇸🇲",
        SN: "🇸🇳",
        SO: "🇸🇴",
        SR: "🇸🇷",
        SS: "🇸🇸",
        ST: "🇸🇹",
        SV: "🇸🇻",
        SX: "🇸🇽",
        SY: "🇸🇾",
        SZ: "🇸🇿",
        TC: "🇹🇨",
        TD: "🇹🇩",
        TF: "🇹🇫",
        TG: "🇹🇬",
        TH: "🇹🇭",
        TJ: "🇹🇯",
        TK: "🇹🇰",
        TL: "🇹🇱",
        TM: "🇹🇲",
        TN: "🇹🇳",
        TO: "🇹🇴",
        TR: "🇹🇷",
        TT: "🇹🇹",
        TV: "🇹🇻",
        TW: "🇹🇼",
        TZ: "🇹🇿",
        UA: "🇺🇦",
        UG: "🇺🇬",
        UM: "🇺🇲",
        US: "🇺🇸",
        UY: "🇺🇾",
        UZ: "🇺🇿",
        VA: "🇻🇦",
        VC: "🇻🇨",
        VE: "🇻🇪",
        VG: "🇻🇬",
        VI: "🇻🇮",
        VN: "🇻🇳",
        VU: "🇻🇺",
        WF: "🇼🇫",
        WS: "🇼🇸",
        YE: "🇾🇪",
        YT: "🇾🇹",
        ZA: "🇿🇦",
        ZM: "🇿🇲",
        ZW: "🇿🇼",
        XX: "🌍",
      };
      return flags[code.toUpperCase()] || "🌍";
    };

    let location = geoData.city || "Unknown";
    if (
      geoData.city !== "Unknown" &&
      geoData.region !== "Unknown" &&
      geoData.city !== geoData.region
    ) {
      location = `${geoData.city}, ${geoData.region}`;
    } else if (geoData.city === "Unknown" && geoData.region !== "Unknown") {
      location = geoData.region;
    } else if (location === "Unknown" && geoData.country !== "Unknown") {
      location = geoData.country;
    }

    const message = `🌐 **NÜ-VISITOR**
\`\`\`
Location: ${location}, ${geoData.country} ${getFlag(geoData.countryCode)}
ISP: ${geoData.isp}
Org: ${geoData.org}
IP: ${ipData.ip}
Timezone: ${geoData.timezone}
ASN: ${geoData.as}
Coords: ${geoData.lat}, ${geoData.lon}
Page: ${location.pathname}
Referrer: ${document.referrer || "Direct"}
\`\`\``;

    // Waiting for @_webhook:t2bot.io
    /*
    await fetch("WEBHOOK_URL", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        text: message,
        format: "org.matrix.custom.html",
        displayName: "nüvis",
      }),
    });
    */
  } catch (error) {
    console.log("Nüvis failed:", error);
  }
})();
