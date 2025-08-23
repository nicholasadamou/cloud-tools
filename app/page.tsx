'use client';

import { PageTransition } from '@/components/page-transition';
import { ServicesSection } from '@/components/ServicesSection';
import { HeroSection } from '@/components/HeroSection';
import { WhyChooseUsSection } from '@/components/WhyChooseUsSection';
import React from 'react';

const Home: React.FC = () => {
  return (
    <PageTransition>
      <div className="flex flex-col">
        <HeroSection />
        <main className="flex-grow">
          <ServicesSection />
          <WhyChooseUsSection />
        </main>
      </div>
    </PageTransition>
  );
};

export default Home;
