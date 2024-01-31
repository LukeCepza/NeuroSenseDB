function Iss = extract_SLP_group(pathin2,pathin3,pathin4, xlimsdis,offset,baseline_SPL,sdur,edur,r1,r2,r3,r4,response)

    Iss = zeros(12,2);
    
    figure()
    [I1,I2,I3,I4] = extract_SLP_epoch(pathin4, 1, xlimsdis, offset, baseline_SPL(3),sdur,edur,0,response);
    
    Iss(9,:) = [mean(I1(r1:r2)),mean(I1(r3:r4))];
    Iss(10,:)  = [mean(I2(r1:r2)),mean(I2(r3:r4))];
    Iss(11,:)  = [mean(I3(r1:r2)),mean(I3(r3:r4))];
    Iss(12,:)  = [mean(I4(r1:r2)),mean(I4(r3:r4))];

    [I1,I2,I3,I4] = extract_SLP_epoch(pathin2, 1, xlimsdis, offset, baseline_SPL(1),sdur,edur,1,response);
    Iss(1,:) = [mean(I1(r1:r2)),mean(I1(r3:r4))];
    Iss(2,:)  = [mean(I2(r1:r2)),mean(I2(r3:r4))];
    Iss(3,:)  = [mean(I3(r1:r2)),mean(I3(r3:r4))];
    Iss(4,:)  = [mean(I4(r1:r2)),mean(I4(r3:r4))];
    
    [I1,I2,I3,I4] = extract_SLP_epoch(pathin3, 1, xlimsdis, offset, baseline_SPL(2),sdur,edur,2,response);
    
    Iss(5,:) = [mean(I1(r1:r2)),mean(I1(r3:r4))];
    Iss(6,:)  = [mean(I2(r1:r2)),mean(I2(r3:r4))];
    Iss(7,:)  = [mean(I3(r1:r2)),mean(I3(r3:r4))];
    Iss(8,:)  = [mean(I4(r1:r2)),mean(I4(r3:r4))];
    
end